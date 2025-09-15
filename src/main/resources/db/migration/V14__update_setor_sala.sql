CREATE OR REPLACE PROCEDURE pr_update_setor(
  IN p_setor_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_caixa NUMERIC(14,2),
  IN p_aberto BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
        v_nome_exists BOOLEAN;
BEGIN
  -- Validações
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome do setor é obrigatório'; END IF;
  IF p_caixa IS NULL OR p_caixa < 0 THEN RAISE EXCEPTION 'Caixa deve ser >= 0'; END IF;

  -- Verifica existência do setor
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Verifica unicidade de nome (excluindo o próprio setor)
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE nome = p_nome AND id <> p_setor_id) INTO v_nome_exists;
  IF v_nome_exists THEN RAISE EXCEPTION 'Já existe um setor com o nome "%"', p_nome; END IF;

  -- Atualiza setor
  UPDATE tb_setores
  SET nome = p_nome,
      caixa = p_caixa,
      aberto = COALESCE(p_aberto, aberto)
  WHERE id = p_setor_id;
END;
$$;


-- Recriar pr_create_sala aceitando p_ativa e usando valor_por_hora
DROP PROCEDURE IF EXISTS pr_create_sala(character varying, numeric, integer, bigint);
CREATE OR REPLACE PROCEDURE pr_create_sala(
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_setor_id BIGINT,
  IN p_ativa BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = p_setor_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, p_setor_id;
  END IF;

  INSERT INTO tb_salas (nome, valor_por_hora, capacidade_maxima, setor_id, ativa)
  VALUES (p_nome, p_valor_por_hora, p_capacidade_maxima, p_setor_id, COALESCE(p_ativa, TRUE));
END;
$$;

-- Recriar pr_update_sala aceitando mudança de setor (p_setor_id)
DROP PROCEDURE IF EXISTS pr_update_sala(bigint, character varying, numeric, integer, boolean);
CREATE OR REPLACE PROCEDURE pr_update_sala(
  IN p_sala_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_ativa BOOLEAN,
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_target_setor_id BIGINT;
        v_target_setor_exists BOOLEAN;
BEGIN
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada', p_sala_id; END IF;

  -- Determina setor alvo: se informado, usa p_setor_id; caso contrário, mantém o atual
  IF p_setor_id IS NOT NULL THEN
    v_target_setor_id := p_setor_id;
  ELSE
    SELECT setor_id INTO v_target_setor_id FROM tb_salas WHERE id = p_sala_id;
  END IF;

  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = v_target_setor_id) INTO v_target_setor_exists;
  IF NOT v_target_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', v_target_setor_id; END IF;

  -- Verifica unicidade do nome no setor alvo, desconsiderando a própria sala
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = v_target_setor_id AND id <> p_sala_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, v_target_setor_id;
  END IF;

  UPDATE tb_salas 
  SET nome = p_nome,
      valor_por_hora = p_valor_por_hora,
      capacidade_maxima = p_capacidade_maxima,
      ativa = COALESCE(p_ativa, ativa),
      setor_id = v_target_setor_id
  WHERE id = p_sala_id;
END;
$$;