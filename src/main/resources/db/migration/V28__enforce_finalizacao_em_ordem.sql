
-- Índice para acelerar a checagem de agendamentos anteriores confirmados
CREATE INDEX IF NOT EXISTS idx_ag_sala_status_inicio ON tb_agendamentos(sala_id, status, data_hora_inicio);

CREATE OR REPLACE PROCEDURE pr_finalizar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE 
  v_agendamento_exists BOOLEAN;
  v_status VARCHAR(20);
  v_inicio TIMESTAMP;
  v_sala_id BIGINT;
  v_valor_restante NUMERIC(14,2);
  v_pf_existente INTEGER;
  v_id_anterior BIGINT;
  v_inicio_anterior TIMESTAMP;
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN 
    RAISE EXCEPTION 'ID do agendamento é obrigatório'; 
  END IF;

  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN 
    RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; 
  END IF;

  -- Carrega dados do agendamento
  SELECT status, data_hora_inicio, sala_id, valor_restante
    INTO v_status, v_inicio, v_sala_id, v_valor_restante
  FROM tb_agendamentos 
  WHERE id = p_agendamento_id;

  -- Regras e mensagens específicas
  IF v_status <> 'CONFIRMADO' THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser finalizado: status atual é %, apenas CONFIRMADO pode ser finalizado.', p_agendamento_id, v_status; 
  END IF;

  IF CURRENT_TIMESTAMP < v_inicio THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser finalizado: horário de início (%) ainda não foi atingido.', p_agendamento_id, to_char(v_inicio, 'DD/MM/YYYY HH24:MI'); 
  END IF;

  -- Verifica se existe algum CONFIRMADO anterior na mesma sala
  SELECT a.id, a.data_hora_inicio
    INTO v_id_anterior, v_inicio_anterior
  FROM tb_agendamentos a
  WHERE a.sala_id = v_sala_id
    AND a.status = 'CONFIRMADO'
    AND a.data_hora_inicio < v_inicio
  ORDER BY a.data_hora_inicio DESC
  LIMIT 1;

  IF v_id_anterior IS NOT NULL THEN
    RAISE EXCEPTION 'Não é possível finalizar o agendamento %: existe agendamento anterior (ID %, início em %) na mesma sala que ainda não foi finalizado.',
      p_agendamento_id, v_id_anterior, to_char(v_inicio_anterior, 'DD/MM/YYYY HH24:MI');
  END IF;

  -- Atualiza o agendamento (gatilhos atualizam caixa e timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'FINALIZADO'
  WHERE id = p_agendamento_id;

  -- Evita duplicidade do pagamento final confirmado
  SELECT COUNT(*) INTO v_pf_existente
  FROM tb_transacoes 
  WHERE agendamento_id = p_agendamento_id 
    AND tipo = 'PAGAMENTO_FINAL' 
    AND status = 'CONFIRMADA';

  IF COALESCE(v_pf_existente, 0) = 0 THEN
    INSERT INTO tb_transacoes (
      agendamento_id, valor, tipo, descricao, metodo_pagamento, status
    ) VALUES (
      p_agendamento_id, v_valor_restante, 'PAGAMENTO_FINAL', 'Pagamento final creditado na finalização do agendamento', 'SISTEMA', 'CONFIRMADA'
    );
  END IF;
END;
$$;