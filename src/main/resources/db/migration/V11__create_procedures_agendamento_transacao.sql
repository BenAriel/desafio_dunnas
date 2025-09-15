
-- Procedure de criar agendamento usando functions
CREATE OR REPLACE PROCEDURE pr_create_agendamento(
  IN p_sala_id BIGINT,
  IN p_cliente_id BIGINT,
  IN p_data_hora_inicio TIMESTAMP,
  IN p_data_fim TIMESTAMP,
  IN p_observacoes VARCHAR(500)
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_cliente_exists BOOLEAN;
        v_valor_total NUMERIC(14,2);
        v_valor_sinal NUMERIC(14,2);
        v_valor_restante NUMERIC(14,2);
        v_sala_disponivel BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_cliente_id IS NULL THEN RAISE EXCEPTION 'ID do cliente é obrigatório'; END IF;
  IF p_data_hora_inicio IS NULL THEN RAISE EXCEPTION 'Data/hora de início é obrigatória'; END IF;
  IF p_data_fim IS NULL THEN RAISE EXCEPTION 'Data/hora de fim é obrigatória'; END IF;

  -- Validações de data
  IF p_data_hora_inicio >= p_data_fim THEN 
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
  SELECT fn_verificar_sala_disponivel(p_sala_id, p_data_hora_inicio, p_data_fim) INTO v_sala_disponivel;
  IF NOT v_sala_disponivel THEN 
    RAISE EXCEPTION 'Sala não está disponível no período especificado'; 
  END IF;

  -- Obtém o valor do aluguel da sala
  SELECT valor_aluguel INTO v_valor_total FROM tb_salas WHERE id = p_sala_id;
  
  -- Usa functions para calcular valores
  v_valor_sinal := fn_calcular_valor_sinal(v_valor_total);
  v_valor_restante := fn_calcular_valor_restante(v_valor_total, v_valor_sinal);

  -- Insere o agendamento (trigger vai validar conflitos automaticamente)
  INSERT INTO tb_agendamentos (
    sala_id, cliente_id, data_hora_inicio, data_hora_fim,
    valor_total, valor_sinal, valor_restante, observacoes
  ) VALUES (
    p_sala_id, p_cliente_id, p_data_hora_inicio, p_data_fim,
    v_valor_total, v_valor_sinal, v_valor_restante, p_observacoes
  );
END;
$$;

-- criar procedure de confirmar agendamento usando functions
CREATE OR REPLACE PROCEDURE pr_confirmar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_pode_confirmar BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  -- Verifica se o agendamento existe
  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  -- Usa function para validar se pode ser confirmado
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

-- criar procedure de finalizar agendamento usando functions
CREATE OR REPLACE PROCEDURE pr_finalizar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_pode_finalizar BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  -- Verifica se o agendamento existe
  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  -- Usa function para validar se pode ser finalizado
  SELECT fn_validar_finalizacao_agendamento(p_agendamento_id) INTO v_pode_finalizar;
  IF NOT v_pode_finalizar THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser finalizado', p_agendamento_id; 
  END IF;

  -- Atualiza o agendamento (trigger vai atualizar caixa e timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'FINALIZADO'
  WHERE id = p_agendamento_id;
END;
$$;

-- criar procedure de criar transação usando functions
CREATE OR REPLACE PROCEDURE pr_create_transacao(
  IN p_agendamento_id BIGINT,
  IN p_valor NUMERIC(14,2),
  IN p_tipo VARCHAR(20),
  IN p_descricao VARCHAR(200),
  IN p_metodo_pagamento VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_agendamento_status VARCHAR(20);
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;
  IF p_valor IS NULL OR p_valor <= 0 THEN RAISE EXCEPTION 'Valor deve ser maior que zero'; END IF;
  IF p_tipo IS NULL OR trim(p_tipo) = '' THEN RAISE EXCEPTION 'Tipo da transação é obrigatório'; END IF;

  -- Valida tipo de transação
  IF p_tipo NOT IN ('SINAL', 'PAGAMENTO_FINAL', 'REEMBOLSO') THEN 
    RAISE EXCEPTION 'Tipo de transação inválido: %. Tipos válidos: SINAL, PAGAMENTO_FINAL, REEMBOLSO', p_tipo; 
  END IF;

  -- Verifica se o agendamento existe
  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  -- Obtém o status do agendamento
  SELECT status INTO v_agendamento_status FROM tb_agendamentos WHERE id = p_agendamento_id;

  -- Validações específicas por tipo
  IF p_tipo = 'SINAL' AND v_agendamento_status != 'SOLICITADO' THEN 
    RAISE EXCEPTION 'Sinal só pode ser pago para agendamentos com status SOLICITADO'; 
  END IF;

  IF p_tipo = 'PAGAMENTO_FINAL' AND v_agendamento_status NOT IN ('CONFIRMADO', 'FINALIZADO') THEN 
    RAISE EXCEPTION 'Pagamento final só pode ser feito para agendamentos CONFIRMADO ou FINALIZADO'; 
  END IF;

  -- Insere a transação
  INSERT INTO tb_transacoes (
    agendamento_id, valor, tipo, descricao, metodo_pagamento, status
  ) VALUES (
    p_agendamento_id, p_valor, p_tipo, p_descricao, p_metodo_pagamento, 'PENDENTE'
  );
END;
$$;

-- criar procedure de confirmar transação usando functions
CREATE OR REPLACE PROCEDURE pr_confirmar_transacao(
  IN p_transacao_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_transacao_exists BOOLEAN;
        v_pode_confirmar BOOLEAN;
        v_tipo VARCHAR(20);
        v_agendamento_id BIGINT;
BEGIN
  -- Validações básicas
  IF p_transacao_id IS NULL THEN RAISE EXCEPTION 'ID da transação é obrigatório'; END IF;

  -- Verifica se a transação existe
  SELECT EXISTS(SELECT 1 FROM tb_transacoes WHERE id = p_transacao_id) INTO v_transacao_exists;
  IF NOT v_transacao_exists THEN RAISE EXCEPTION 'Transação % não encontrada', p_transacao_id; END IF;

  -- Usa function para validar se pode ser confirmada
  SELECT fn_validar_confirmacao_transacao(p_transacao_id) INTO v_pode_confirmar;
  IF NOT v_pode_confirmar THEN 
    RAISE EXCEPTION 'Transação % não pode ser confirmada', p_transacao_id; 
  END IF;

  -- Obtém dados da transação
  SELECT tipo, agendamento_id INTO v_tipo, v_agendamento_id 
  FROM tb_transacoes WHERE id = p_transacao_id;

  -- Atualiza a transação
  UPDATE tb_transacoes 
  SET status = 'CONFIRMADA'
  WHERE id = p_transacao_id;

  -- Se for sinal, confirma o agendamento automaticamente
  IF v_tipo = 'SINAL' THEN
    CALL pr_confirmar_agendamento(v_agendamento_id);
  END IF;

  -- Se for pagamento final, finaliza o agendamento
  IF v_tipo = 'PAGAMENTO_FINAL' THEN
    CALL pr_finalizar_agendamento(v_agendamento_id);
  END IF;
END;
$$;

-- criar procedure de abrir setor usando functions
CREATE OR REPLACE PROCEDURE pr_abrir_setor(
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
        v_recepcionista_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;

  -- Verifica se o setor existe
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Verifica se o setor tem recepcionista
  SELECT EXISTS(SELECT 1 FROM tb_recepcionistas WHERE setor_id = p_setor_id) INTO v_recepcionista_exists;
  IF NOT v_recepcionista_exists THEN RAISE EXCEPTION 'Setor % não possui recepcionista alocado', p_setor_id; END IF;

  -- Abre o setor
  UPDATE tb_setores 
  SET aberto = TRUE
  WHERE id = p_setor_id;
END;
$$;

-- criar procedure de fechar setor usando functions
CREATE OR REPLACE PROCEDURE pr_fechar_setor(
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;

  -- Verifica se o setor existe
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Fecha o setor
  UPDATE tb_setores 
  SET aberto = FALSE
  WHERE id = p_setor_id;
END;
$$;
