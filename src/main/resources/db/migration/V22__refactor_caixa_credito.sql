
-- Centralizar toda a lógica de crédito do caixa no trigger da tabela de transações,
-- removendo a lógica redundante que existia na tabela de agendamentos.

-- Remover o trigger e a função redundantes da tabela de agendamentos.
DROP TRIGGER IF EXISTS tr_agendamento_finalizado_credito ON tb_agendamentos;

DROP FUNCTION IF EXISTS tr_finalizar_agendamento_creditar_caixa();


-- A função é modificada para creditar o caixa sempre que uma transação do tipo 'SINAL'
-- ou 'PAGAMENTO_FINAL' for confirmada (seja em um INSERT ou UPDATE).

CREATE OR REPLACE FUNCTION tr_creditar_caixa_ao_confirmar_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_setor_id BIGINT;
    v_agendamento_id BIGINT;
    v_valor NUMERIC(14,2);
    v_deve_creditar BOOLEAN := FALSE;
BEGIN
    -- Verifica se a operação é um INSERT de uma transação já confirmada
    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL') THEN
            v_deve_creditar := TRUE;
        END IF;
    -- Verifica se a operação é um UPDATE que está confirmando uma transação
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.status = 'CONFIRMADA' AND OLD.status != 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL') THEN
            v_deve_creditar := TRUE;
        END IF;
    END IF;

    -- Se a condição de crédito for atendida, atualiza o caixa do setor correspondente
    IF v_deve_creditar THEN
        v_agendamento_id := NEW.agendamento_id;
        
        -- Encontra o setor associado ao agendamento
        SELECT s.setor_id INTO v_setor_id
        FROM tb_agendamentos a
        JOIN tb_salas s ON s.id = a.sala_id
        WHERE a.id = v_agendamento_id;

        -- Credita o valor da transação no caixa do setor
        v_valor := NEW.valor;
        UPDATE tb_setores SET caixa = caixa + v_valor WHERE id = v_setor_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_transacao_confirmada_credito ON tb_transacoes;
CREATE TRIGGER tr_transacao_confirmada_credito
  AFTER INSERT OR UPDATE ON tb_transacoes
  FOR EACH ROW
  EXECUTE FUNCTION tr_creditar_caixa_ao_confirmar_transacao();