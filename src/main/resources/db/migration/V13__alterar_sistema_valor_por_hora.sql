

-- Renomear coluna valor_aluguel para valor_por_hora
ALTER TABLE tb_salas RENAME COLUMN valor_aluguel TO valor_por_hora;

-- Atualizar comentário da coluna
COMMENT ON COLUMN tb_salas.valor_por_hora IS 'Valor do aluguel por hora em reais';

--Criar function para calcular valor total baseado nas horas
CREATE OR REPLACE FUNCTION fn_calcular_valor_total_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_horas NUMERIC(14,2);
BEGIN
  -- Calcula a diferença em horas (arredondando para cima)
  v_horas := CEIL(EXTRACT(EPOCH FROM (p_data_fim - p_data_inicio)) / 3600);
  
  -- Retorna o valor total (valor por hora * número de horas)
  RETURN p_valor_por_hora * v_horas;
END;
$$;

-- 4. Atualizar function de calcular valor do sinal para usar nova lógica
CREATE OR REPLACE FUNCTION fn_calcular_valor_sinal_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_valor_total NUMERIC(14,2);
BEGIN
  -- Calcula o valor total primeiro
  v_valor_total := fn_calcular_valor_total_por_horas(p_valor_por_hora, p_data_inicio, p_data_fim);
  
  -- Retorna 50% do valor total
  RETURN v_valor_total * 0.5;
END;
$$;

--Atualizar function de calcular valor restante
CREATE OR REPLACE FUNCTION fn_calcular_valor_restante_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP,
  p_valor_sinal NUMERIC(14,2)
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_valor_total NUMERIC(14,2);
BEGIN
  -- Calcula o valor total primeiro
  v_valor_total := fn_calcular_valor_total_por_horas(p_valor_por_hora, p_data_inicio, p_data_fim);
  
  -- Retorna o valor restante (valor total - valor sinal)
  RETURN v_valor_total - p_valor_sinal;
END;
$$;


-- recriar a procedure com novos nomes de parâmetros
DROP PROCEDURE IF EXISTS pr_create_sala(character varying, numeric, integer, bigint);
CREATE OR REPLACE PROCEDURE pr_create_sala(
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;

  -- Verifica se o setor existe
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Verifica se já existe sala com o mesmo nome no setor
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = p_setor_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, p_setor_id;
  END IF;

  -- Insere a sala
  INSERT INTO tb_salas (nome, valor_por_hora, capacidade_maxima, setor_id, ativa)
  VALUES (p_nome, p_valor_por_hora, p_capacidade_maxima, p_setor_id, TRUE);
END;
$$;


-- recriar a procedure com novos nomes de parâmetros
DROP PROCEDURE IF EXISTS pr_update_sala(bigint, character varying, numeric, integer, boolean);
CREATE OR REPLACE PROCEDURE pr_update_sala(
  IN p_sala_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_ativa BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_setor_id BIGINT;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;

  -- Verifica se a sala existe
  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada', p_sala_id; END IF;

  -- Obtém o setor_id da sala
  SELECT setor_id INTO v_setor_id FROM tb_salas WHERE id = p_sala_id;

  -- Verifica se já existe outra sala com o mesmo nome no mesmo setor
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = v_setor_id AND id != p_sala_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, v_setor_id;
  END IF;

  -- Atualiza a sala
  UPDATE tb_salas 
  SET nome = p_nome, 
      valor_por_hora = p_valor_por_hora, 
      capacidade_maxima = p_capacidade_maxima,
      ativa = COALESCE(p_ativa, ativa)
  WHERE id = p_sala_id;
END;
$$;

--  recriar a procedure com novos nomes de parâmetros
DROP PROCEDURE IF EXISTS pr_create_agendamento(bigint, bigint, timestamp without time zone, timestamp without time zone, character varying);
CREATE OR REPLACE PROCEDURE pr_create_agendamento(
  IN p_sala_id BIGINT,
  IN p_cliente_id BIGINT,
  IN p_data_hora_inicio TIMESTAMP,
  IN p_data_hora_fim TIMESTAMP,
  IN p_observacoes VARCHAR(500)
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_cliente_exists BOOLEAN;
        v_valor_por_hora NUMERIC(14,2);
        v_valor_total NUMERIC(14,2);
        v_valor_sinal NUMERIC(14,2);
        v_valor_restante NUMERIC(14,2);
        v_sala_disponivel BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_cliente_id IS NULL THEN RAISE EXCEPTION 'ID do cliente é obrigatório'; END IF;
  IF p_data_hora_inicio IS NULL THEN RAISE EXCEPTION 'Data/hora de início é obrigatória'; END IF;
  IF p_data_hora_fim IS NULL THEN RAISE EXCEPTION 'Data/hora de fim é obrigatória'; END IF;

  -- Validações de data
  IF p_data_hora_inicio >= p_data_hora_fim THEN 
    RAISE EXCEPTION 'Data/hora de início deve ser anterior à data/hora de fim'; 
  END IF;

  IF p_data_hora_inicio <= CURRENT_TIMESTAMP THEN 
    RAISE EXCEPTION 'Data/hora de início deve ser futura'; 
  END IF;

  -- Verifica se a sala existe e está ativa
  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id AND ativa = TRUE) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada ou inativa', p_sala_id; END IF;

  -- Verifica se o cliente existe
  SELECT EXISTS(SELECT 1 FROM tb_clientes WHERE id = p_cliente_id) INTO v_cliente_exists;
  IF NOT v_cliente_exists THEN RAISE EXCEPTION 'Cliente % não encontrado', p_cliente_id; END IF;

  -- Usa function para verificar disponibilidade da sala
  SELECT fn_verificar_sala_disponivel(p_sala_id, p_data_hora_inicio, p_data_hora_fim) INTO v_sala_disponivel;
  IF NOT v_sala_disponivel THEN 
    RAISE EXCEPTION 'Sala não está disponível no período especificado'; 
  END IF;

  -- Obtém o valor por hora da sala
  SELECT valor_por_hora INTO v_valor_por_hora FROM tb_salas WHERE id = p_sala_id;
  
  -- Calcula valores usando as novas functions
  v_valor_total := fn_calcular_valor_total_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim);
  v_valor_sinal := fn_calcular_valor_sinal_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim);
  v_valor_restante := fn_calcular_valor_restante_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim, v_valor_sinal);

  -- Insere o agendamento
  INSERT INTO tb_agendamentos (
    sala_id, 
    cliente_id, 
    data_hora_inicio, 
    data_hora_fim, 
    valor_total, 
    valor_sinal, 
    valor_restante, 
    observacoes, 
    status
  ) VALUES (
    p_sala_id, 
    p_cliente_id, 
    p_data_hora_inicio, 
    p_data_hora_fim, 
    v_valor_total, 
    v_valor_sinal, 
    v_valor_restante, 
    p_observacoes, 
    'SOLICITADO'
  );
END;
$$;

--Atualizar dados de exemplo para usar valores por hora mais realistas
UPDATE tb_salas SET valor_por_hora = 50.00 WHERE nome = 'Sala de Reunião A';
UPDATE tb_salas SET valor_por_hora = 75.00 WHERE nome = 'Sala de Reunião B';
UPDATE tb_salas SET valor_por_hora = 100.00 WHERE nome = 'Auditório Principal';
UPDATE tb_salas SET valor_por_hora = 30.00 WHERE nome = 'Sala de Treinamento';
UPDATE tb_salas SET valor_por_hora = 60.00 WHERE nome = 'Sala de Conferência';
