
CREATE OR REPLACE FUNCTION fn_relatorio_agendamentos_setor(
  p_setor_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS TABLE (
  agendamento_id BIGINT,
  sala_nome VARCHAR(100),
  cliente_nome VARCHAR(100),
  data_inicio TIMESTAMP,
  data_fim TIMESTAMP,
  valor_total NUMERIC(14,2),
  status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    s.nome,
    u.nome,
    a.data_hora_inicio,
    a.data_hora_fim,
    a.valor_total,
    a.status
  FROM tb_agendamentos a
  JOIN tb_salas s ON a.sala_id = s.id
  JOIN tb_clientes c ON a.cliente_id = c.id
  JOIN tb_usuarios u ON c.usuario_id = u.id
  WHERE s.setor_id = p_setor_id
  AND a.data_hora_inicio >= p_data_inicio
  AND a.data_hora_inicio <= p_data_fim
  ORDER BY a.data_hora_inicio;
END;
$$;

-- Function para obter relatório de transações por setor e período
CREATE OR REPLACE FUNCTION fn_relatorio_transacoes_setor(
  p_setor_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS TABLE (
  transacao_id BIGINT,
  agendamento_id BIGINT,
  cliente_nome VARCHAR(100),
  valor NUMERIC(14,2),
  tipo VARCHAR(20),
  status VARCHAR(20),
  data_transacao TIMESTAMP,
  metodo_pagamento VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    t.id,
    t.agendamento_id,
    u.nome,
    t.valor,
    t.tipo,
    t.status,
    t.data_transacao,
    t.metodo_pagamento
  FROM tb_transacoes t
  JOIN tb_agendamentos a ON t.agendamento_id = a.id
  JOIN tb_salas s ON a.sala_id = s.id
  JOIN tb_clientes c ON a.cliente_id = c.id
  JOIN tb_usuarios u ON c.usuario_id = u.id
  WHERE s.setor_id = p_setor_id
  AND t.data_transacao >= p_data_inicio
  AND t.data_transacao <= p_data_fim
  ORDER BY t.data_transacao DESC;
END;
$$;

-- Function para obter estatísticas de ocupação de salas
CREATE OR REPLACE FUNCTION fn_estatisticas_ocupacao_sala(
  p_sala_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS TABLE (
  total_agendamentos BIGINT,
  total_horas_reservadas NUMERIC,
  valor_total_arrecadado NUMERIC(14,2),
  taxa_ocupacao NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
DECLARE v_total_agendamentos BIGINT;
        v_total_horas NUMERIC;
        v_valor_total NUMERIC(14,2);
        v_periodo_horas NUMERIC;
        v_taxa_ocupacao NUMERIC(5,2);
BEGIN
  -- Conta total de agendamentos
  SELECT COUNT(*) INTO v_total_agendamentos
  FROM tb_agendamentos
  WHERE sala_id = p_sala_id
  AND data_hora_inicio >= p_data_inicio
  AND data_hora_inicio <= p_data_fim
  AND status IN ('CONFIRMADO', 'FINALIZADO');

  -- Calcula total de horas reservadas
  SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (data_hora_fim - data_hora_inicio)) / 3600), 0) INTO v_total_horas
  FROM tb_agendamentos
  WHERE sala_id = p_sala_id
  AND data_hora_inicio >= p_data_inicio
  AND data_hora_inicio <= p_data_fim
  AND status IN ('CONFIRMADO', 'FINALIZADO');

  -- Calcula valor total arrecadado
  SELECT COALESCE(SUM(valor_total), 0) INTO v_valor_total
  FROM tb_agendamentos
  WHERE sala_id = p_sala_id
  AND data_hora_inicio >= p_data_inicio
  AND data_hora_inicio <= p_data_fim
  AND status = 'FINALIZADO';

  -- Calcula período total em horas
  v_periodo_horas := EXTRACT(EPOCH FROM (p_data_fim - p_data_inicio)) / 3600;

  -- Calcula taxa de ocupação (assumindo que a sala pode ser usada 24h por dia)
  IF v_periodo_horas > 0 THEN
    v_taxa_ocupacao := (v_total_horas / v_periodo_horas) * 100;
  ELSE
    v_taxa_ocupacao := 0;
  END IF;

  RETURN QUERY SELECT v_total_agendamentos, v_total_horas, v_valor_total, v_taxa_ocupacao;
END;
$$;

-- Function para obter salas disponíveis em um período
CREATE OR REPLACE FUNCTION fn_salas_disponiveis_periodo(
  p_setor_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS TABLE (
  sala_id BIGINT,
  sala_nome VARCHAR(100),
  valor_aluguel NUMERIC(14,2),
  capacidade_maxima INTEGER,
  disponivel BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.nome,
    s.valor_aluguel,
    s.capacidade_maxima,
    fn_verificar_sala_disponivel(s.id, p_data_inicio, p_data_fim) as disponivel
  FROM tb_salas s
  WHERE s.setor_id = p_setor_id
  AND s.ativa = TRUE
  ORDER BY s.nome;
END;
$$;

-- Function para obter resumo financeiro do setor
CREATE OR REPLACE FUNCTION fn_resumo_financeiro_setor(
  p_setor_id BIGINT,
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS TABLE (
  total_arrecadado NUMERIC(14,2),
  total_sinais NUMERIC(14,2),
  total_pagamentos_finais NUMERIC(14,2),
  total_reembolsos NUMERIC(14,2),
  caixa_atual NUMERIC(14,2),
  agendamentos_finalizados BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_total_arrecadado NUMERIC(14,2);
        v_total_sinais NUMERIC(14,2);
        v_total_pagamentos_finais NUMERIC(14,2);
        v_total_reembolsos NUMERIC(14,2);
        v_caixa_atual NUMERIC(14,2);
        v_agendamentos_finalizados BIGINT;
BEGIN
  -- Total arrecadado (agendamentos finalizados)
  SELECT COALESCE(SUM(valor_total), 0) INTO v_total_arrecadado
  FROM tb_agendamentos a
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND a.data_hora_inicio >= p_data_inicio
  AND a.data_hora_inicio <= p_data_fim
  AND a.status = 'FINALIZADO';

  -- Total de sinais
  SELECT COALESCE(SUM(t.valor), 0) INTO v_total_sinais
  FROM tb_transacoes t
  JOIN tb_agendamentos a ON t.agendamento_id = a.id
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND t.data_transacao >= p_data_inicio
  AND t.data_transacao <= p_data_fim
  AND t.tipo = 'SINAL'
  AND t.status = 'CONFIRMADA';

  -- Total de pagamentos finais
  SELECT COALESCE(SUM(t.valor), 0) INTO v_total_pagamentos_finais
  FROM tb_transacoes t
  JOIN tb_agendamentos a ON t.agendamento_id = a.id
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND t.data_transacao >= p_data_inicio
  AND t.data_transacao <= p_data_fim
  AND t.tipo = 'PAGAMENTO_FINAL'
  AND t.status = 'CONFIRMADA';

  -- Total de reembolsos
  SELECT COALESCE(SUM(t.valor), 0) INTO v_total_reembolsos
  FROM tb_transacoes t
  JOIN tb_agendamentos a ON t.agendamento_id = a.id
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND t.data_transacao >= p_data_inicio
  AND t.data_transacao <= p_data_fim
  AND t.tipo = 'REEMBOLSO'
  AND t.status = 'CONFIRMADA';

  -- Caixa atual do setor
  SELECT caixa INTO v_caixa_atual FROM tb_setores WHERE id = p_setor_id;

  -- Agendamentos finalizados
  SELECT COUNT(*) INTO v_agendamentos_finalizados
  FROM tb_agendamentos a
  JOIN tb_salas s ON a.sala_id = s.id
  WHERE s.setor_id = p_setor_id
  AND a.data_hora_inicio >= p_data_inicio
  AND a.data_hora_inicio <= p_data_fim
  AND a.status = 'FINALIZADO';

  RETURN QUERY SELECT 
    v_total_arrecadado,
    v_total_sinais,
    v_total_pagamentos_finais,
    v_total_reembolsos,
    v_caixa_atual,
    v_agendamentos_finalizados;
END;
$$;
