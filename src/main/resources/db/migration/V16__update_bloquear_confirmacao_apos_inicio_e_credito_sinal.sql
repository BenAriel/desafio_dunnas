-- Atualiza a function de validação de confirmação para considerar data_hora_inicio > now()
CREATE OR REPLACE FUNCTION fn_validar_confirmacao_agendamento(p_agendamento_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
        v_inicio TIMESTAMP;
BEGIN
  SELECT status, data_hora_inicio INTO v_status, v_inicio FROM tb_agendamentos WHERE id = p_agendamento_id;
  RETURN v_status = 'SOLICITADO' AND v_inicio > CURRENT_TIMESTAMP;
END;
$$;


-- Cria trigger em tb_transacoes após atualização de status para CONFIRMADA
CREATE OR REPLACE FUNCTION tr_creditar_caixa_ao_confirmar_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_setor_id BIGINT;
        v_agendamento_id BIGINT;
        v_valor NUMERIC(14,2);
BEGIN
  -- somente quando a transação muda para CONFIRMADA
  IF NEW.status = 'CONFIRMADA' AND OLD.status != 'CONFIRMADA' THEN
    -- localizar agendamento e setor
    v_agendamento_id := NEW.agendamento_id;
    SELECT s.setor_id INTO v_setor_id
    FROM tb_agendamentos a
    JOIN tb_salas s ON s.id = a.sala_id
    WHERE a.id = v_agendamento_id;

    -- se sinal, creditar valor no caixa
    IF NEW.tipo = 'SINAL' THEN
      v_valor := NEW.valor;
      UPDATE tb_setores SET caixa = caixa + v_valor WHERE id = v_setor_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_transacao_confirmada_credito ON tb_transacoes;
CREATE TRIGGER tr_transacao_confirmada_credito
  AFTER UPDATE ON tb_transacoes
  FOR EACH ROW
  EXECUTE FUNCTION tr_creditar_caixa_ao_confirmar_transacao();


