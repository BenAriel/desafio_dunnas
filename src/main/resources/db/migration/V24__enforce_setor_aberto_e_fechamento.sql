
-- Fechamento de setor condicionado a não haver agendamentos CONFIRMADOS ou SOLICITADOS
CREATE OR REPLACE PROCEDURE pr_fechar_setor(
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_setor_exists BOOLEAN;
    v_agendamentos_confirmados_count INT;
BEGIN
  -- Validações básicas
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;

  -- Verifica se o setor existe
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Verifica se existem agendamentos CONFIRMADOS ou SOLICITADOS para as salas deste setor
  SELECT COUNT(a.id)
  INTO v_agendamentos_confirmados_count
  FROM tb_agendamentos a
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
    AND a.status IN ('CONFIRMADO', 'SOLICITADO');

  -- Se houver agendamentos confirmados/solicitados, impede o fechamento
  IF v_agendamentos_confirmados_count > 0 THEN
    RAISE EXCEPTION 'Não é possível fechar o setor, pois existem % agendamento(s) confirmado(s) ou solicitado(s).', v_agendamentos_confirmados_count;
  END IF;

  -- Fecha o setor
  UPDATE tb_setores 
  SET aberto = FALSE
  WHERE id = p_setor_id;
END;
$$;

--  Criar agendamento somente com setor aberto
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
        v_setor_aberto BOOLEAN;
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

  -- Verifica se o setor da sala está aberto
  SELECT se.aberto INTO v_setor_aberto
  FROM tb_salas s
  JOIN tb_setores se ON s.setor_id = se.id
  WHERE s.id = p_sala_id;

  IF NOT v_setor_aberto THEN
      RAISE EXCEPTION 'Não é possível criar agendamento, pois o setor da sala está fechado.';
  END IF;

  -- Verifica se o cliente existe
  SELECT EXISTS(SELECT 1 FROM tb_clientes WHERE id = p_cliente_id) INTO v_cliente_exists;
  IF NOT v_cliente_exists THEN RAISE EXCEPTION 'Cliente % não encontrado', p_cliente_id; END IF;

  -- Usa function para verificar disponibilidade da sala
  SELECT fn_verificar_sala_disponivel(p_sala_id, p_data_hora_inicio, p_data_hora_fim) INTO v_sala_disponivel;
  IF NOT v_sala_disponivel THEN 
    RAISE EXCEPTION 'Sala não está disponível no período especificado'; 
  END IF;

  SELECT valor_por_hora INTO v_valor_por_hora FROM tb_salas WHERE id = p_sala_id;
  
  -- Calcula valores usando functions baseadas em horas
  v_valor_total := fn_calcular_valor_total_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim);
  v_valor_sinal := fn_calcular_valor_sinal_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim);
  v_valor_restante := fn_calcular_valor_restante_por_horas(v_valor_por_hora, p_data_hora_inicio, p_data_hora_fim, v_valor_sinal);

  -- Insere o agendamento (trigger vai validar conflitos automaticamente)
  INSERT INTO tb_agendamentos (
    sala_id, cliente_id, data_hora_inicio, data_hora_fim,
    valor_total, valor_sinal, valor_restante, observacoes
  ) VALUES (
    p_sala_id, p_cliente_id, p_data_hora_inicio, p_data_hora_fim,
    v_valor_total, v_valor_sinal, v_valor_restante, p_observacoes
  );
END;
$$;

-- Confirmar agendamento somente com setor aberto
CREATE OR REPLACE PROCEDURE pr_confirmar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_pode_confirmar BOOLEAN;
        v_setor_aberto BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  -- Verifica se o agendamento existe
  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  -- Verifica se o setor do agendamento está aberto
  SELECT se.aberto INTO v_setor_aberto
  FROM tb_agendamentos a
  JOIN tb_salas s ON s.id = a.sala_id
  JOIN tb_setores se ON se.id = s.setor_id
  WHERE a.id = p_agendamento_id;

  IF NOT v_setor_aberto THEN
      RAISE EXCEPTION 'Não é possível confirmar agendamento, pois o setor está fechado.';
  END IF;

  -- Usa function para validar se pode ser confirmado (regras existentes)
  SELECT fn_validar_confirmacao_agendamento(p_agendamento_id) INTO v_pode_confirmar;
  IF NOT v_pode_confirmar THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser confirmado', p_agendamento_id; 
  END IF;

  -- Atualiza o agendamento (trigger vai atualizar timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'CONFIRMADO'
  WHERE id = p_agendamento_id;
END;
$$;
