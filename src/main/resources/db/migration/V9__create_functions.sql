

-- Function para calcular valor do sinal (50% do valor total)
CREATE OR REPLACE FUNCTION fn_calcular_valor_sinal(valor_total NUMERIC(14,2))
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN valor_total * 0.5;
END;
$$;

-- Function para calcular valor restante
CREATE OR REPLACE FUNCTION fn_calcular_valor_restante(valor_total NUMERIC(14,2), valor_sinal NUMERIC(14,2))
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN valor_total - valor_sinal;
END;
$$;

-- Function para verificar se há conflito de agendamento
CREATE OR REPLACE FUNCTION fn_verificar_conflito_agendamento(
  p_sala_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP,
  p_agendamento_id BIGINT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_conflito_count INTEGER;
BEGIN
  IF p_agendamento_id IS NULL THEN
    -- Verificação para novo agendamento
    SELECT COUNT(*) INTO v_conflito_count
    FROM tb_agendamentos 
    WHERE sala_id = p_sala_id 
    AND status IN ('CONFIRMADO', 'FINALIZADO')
    AND ((data_hora_inicio <= p_data_fim AND data_hora_fim >= p_data_inicio));
  ELSE
    -- Verificação para atualização de agendamento existente
    SELECT COUNT(*) INTO v_conflito_count
    FROM tb_agendamentos 
    WHERE sala_id = p_sala_id 
    AND status IN ('CONFIRMADO', 'FINALIZADO')
    AND id != p_agendamento_id
    AND ((data_hora_inicio <= p_data_fim AND data_hora_fim >= p_data_inicio));
  END IF;
  
  RETURN v_conflito_count > 0;
END;
$$;

-- Function para verificar se sala está disponível
CREATE OR REPLACE FUNCTION fn_verificar_sala_disponivel(
  p_sala_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_sala_ativa BOOLEAN;
        v_conflito BOOLEAN;
BEGIN
  -- Verifica se a sala está ativa
  SELECT ativa INTO v_sala_ativa FROM tb_salas WHERE id = p_sala_id;
  
  IF NOT v_sala_ativa THEN
    RETURN FALSE;
  END IF;
  
  -- Verifica se há conflito
  SELECT fn_verificar_conflito_agendamento(p_sala_id, p_data_inicio, p_data_fim) INTO v_conflito;
  
  RETURN NOT v_conflito;
END;
$$;

-- Function para obter valor total de transações confirmadas por período
CREATE OR REPLACE FUNCTION fn_somar_transacoes_confirmadas_periodo(
  p_setor_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_total NUMERIC(14,2);
BEGIN
  SELECT COALESCE(SUM(t.valor), 0) INTO v_total
  FROM tb_transacoes t
  JOIN tb_agendamentos a ON t.agendamento_id = a.id
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND t.data_transacao >= p_data_inicio 
  AND t.data_transacao <= p_data_fim
  AND t.status = 'CONFIRMADA';
  
  RETURN v_total;
END;
$$;

-- Function para validar se agendamento pode ser confirmado
CREATE OR REPLACE FUNCTION fn_validar_confirmacao_agendamento(p_agendamento_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
BEGIN
  SELECT status INTO v_status FROM tb_agendamentos WHERE id = p_agendamento_id;
  RETURN v_status = 'SOLICITADO';
END;
$$;

-- Function para validar se agendamento pode ser finalizado
CREATE OR REPLACE FUNCTION fn_validar_finalizacao_agendamento(p_agendamento_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
BEGIN
  SELECT status INTO v_status FROM tb_agendamentos WHERE id = p_agendamento_id;
  RETURN v_status = 'CONFIRMADO';
END;
$$;

-- Function para validar se transação pode ser confirmada
CREATE OR REPLACE FUNCTION fn_validar_confirmacao_transacao(p_transacao_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
BEGIN
  SELECT status INTO v_status FROM tb_transacoes WHERE id = p_transacao_id;
  RETURN v_status = 'PENDENTE';
END;
$$;

-- Function para obter setor de uma sala
CREATE OR REPLACE FUNCTION fn_obter_setor_da_sala(p_sala_id BIGINT)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE v_setor_id BIGINT;
BEGIN
  SELECT setor_id INTO v_setor_id FROM tb_salas WHERE id = p_sala_id;
  RETURN v_setor_id;
END;
$$;
