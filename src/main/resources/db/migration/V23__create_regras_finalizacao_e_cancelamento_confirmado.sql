-- Impedir finalização antes do horário de início
CREATE OR REPLACE FUNCTION fn_validar_finalizacao_agendamento(p_agendamento_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
        v_inicio TIMESTAMP;
BEGIN
  SELECT status, data_hora_inicio INTO v_status, v_inicio FROM tb_agendamentos WHERE id = p_agendamento_id;
  RETURN v_status = 'CONFIRMADO' AND CURRENT_TIMESTAMP >= v_inicio;
END;
$$;

--  Permitir cancelamento de CONFIRMADO antes do início com reembolso do sinal
-- Atualiza a procedure de cancelamento para cobrir SOLICITADO e CONFIRMADO(<inicio)
CREATE OR REPLACE PROCEDURE pr_cancelar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_exists BOOLEAN;
        v_status VARCHAR(20);
        v_inicio TIMESTAMP;
        v_valor_sinal NUMERIC(14,2);
        v_reembolso_existente INTEGER;
BEGIN
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_exists;
  IF NOT v_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  SELECT status, data_hora_inicio, valor_sinal INTO v_status, v_inicio, v_valor_sinal
  FROM tb_agendamentos WHERE id = p_agendamento_id;

  IF v_status = 'SOLICITADO' THEN
    UPDATE tb_agendamentos SET status = 'CANCELADO' WHERE id = p_agendamento_id;
    RETURN;
  END IF;

  IF v_status = 'CONFIRMADO' AND CURRENT_TIMESTAMP < v_inicio THEN
    UPDATE tb_agendamentos SET status = 'CANCELADO' WHERE id = p_agendamento_id;

    -- evitar duplicidade de reembolso
    SELECT COUNT(*) INTO v_reembolso_existente
    FROM tb_transacoes
    WHERE agendamento_id = p_agendamento_id
      AND tipo = 'REEMBOLSO'
      AND status = 'CONFIRMADA';

    IF COALESCE(v_reembolso_existente, 0) = 0 AND v_valor_sinal IS NOT NULL AND v_valor_sinal > 0 THEN
      -- insere REEMBOLSO CONFIRMADO (gatilha debita do caixa)
      INSERT INTO tb_transacoes (
        agendamento_id, valor, tipo, descricao, metodo_pagamento, status
      ) VALUES (
        p_agendamento_id, v_valor_sinal, 'REEMBOLSO', 'Reembolso do sinal por cancelamento antes do início', 'SISTEMA', 'CONFIRMADA'
      );
    END IF;

    RETURN;
  END IF;

  RAISE EXCEPTION 'Agendamento % não pode ser cancelado neste status/horário', p_agendamento_id;
END;
$$;

-- Atualizar trigger detransações para tratar REEMBOLSO como débito
CREATE OR REPLACE FUNCTION tr_creditar_caixa_ao_confirmar_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_setor_id BIGINT;
    v_agendamento_id BIGINT;
    v_valor NUMERIC(14,2);
    v_deve_processar BOOLEAN := FALSE;
    v_sinal INTEGER := 0;
    v_pagfinal INTEGER := 0;
    v_reembolso INTEGER := 0;
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL', 'REEMBOLSO') THEN
            v_deve_processar := TRUE;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.status = 'CONFIRMADA' AND OLD.status != 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL', 'REEMBOLSO') THEN
            v_deve_processar := TRUE;
        END IF;
    END IF;

    IF v_deve_processar THEN
        v_agendamento_id := NEW.agendamento_id;
        SELECT s.setor_id INTO v_setor_id
        FROM tb_agendamentos a
        JOIN tb_salas s ON s.id = a.sala_id
        WHERE a.id = v_agendamento_id;

        v_valor := NEW.valor;

        IF NEW.tipo = 'REEMBOLSO' THEN
            -- débito do caixa
            UPDATE tb_setores SET caixa = caixa - v_valor WHERE id = v_setor_id;
        ELSE
            -- crédito do caixa
            UPDATE tb_setores SET caixa = caixa + v_valor WHERE id = v_setor_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_transacao_confirmada_credito ON tb_transacoes;
CREATE TRIGGER tr_transacao_confirmada_credito
  AFTER INSERT OR UPDATE ON tb_transacoes
  FOR EACH ROW
  EXECUTE FUNCTION tr_creditar_caixa_ao_confirmar_transacao();


