-- Garantir crédito no caixa ao confirmar transação de SINAL em INSERT ou UPDATE

CREATE OR REPLACE FUNCTION tr_creditar_caixa_ao_confirmar_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_setor_id BIGINT;
        v_agendamento_id BIGINT;
        v_valor NUMERIC(14,2);
        v_deve_creditar BOOLEAN := FALSE;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'CONFIRMADA' AND NEW.tipo = 'SINAL' THEN
      v_deve_creditar := TRUE;
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.status = 'CONFIRMADA' AND OLD.status != 'CONFIRMADA' AND NEW.tipo = 'SINAL' THEN
      v_deve_creditar := TRUE;
    END IF;
  END IF;

  IF v_deve_creditar THEN
    v_agendamento_id := NEW.agendamento_id;
    SELECT s.setor_id INTO v_setor_id
    FROM tb_agendamentos a
    JOIN tb_salas s ON s.id = a.sala_id
    WHERE a.id = v_agendamento_id;

    v_valor := NEW.valor;
    UPDATE tb_setores SET caixa = caixa + v_valor WHERE id = v_setor_id;
  END IF;

  RETURN NEW;
END;
$$;

-- Recriar trigger para pegar INSERT e UPDATE
DROP TRIGGER IF EXISTS tr_transacao_confirmada_credito ON tb_transacoes;
CREATE TRIGGER tr_transacao_confirmada_credito
  AFTER INSERT OR UPDATE ON tb_transacoes
  FOR EACH ROW
  EXECUTE FUNCTION tr_creditar_caixa_ao_confirmar_transacao();


