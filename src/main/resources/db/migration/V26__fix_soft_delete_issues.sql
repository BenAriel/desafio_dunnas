--Adiciona coluna ausente em tb_setores
ALTER TABLE tb_setores ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES tb_usuarios(id);


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
    FROM tb_agendamentos a
    JOIN tb_salas s ON s.id = a.sala_id
    WHERE a.sala_id = p_sala_id 
      AND s.deleted_at IS NULL  -- sala não soft deleted
      AND a.status IN ('CONFIRMADO', 'FINALIZADO')
      AND (a.data_hora_inicio < p_data_fim AND a.data_hora_fim > p_data_inicio);
  ELSE
    -- Verificação para atualização de agendamento existente
    SELECT COUNT(*) INTO v_conflito_count
    FROM tb_agendamentos a
    JOIN tb_salas s ON s.id = a.sala_id
    WHERE a.sala_id = p_sala_id 
      AND s.deleted_at IS NULL  -- sala não soft deleted
      AND a.status IN ('CONFIRMADO', 'FINALIZADO')
      AND a.id != p_agendamento_id
      AND (a.data_hora_inicio < p_data_fim AND a.data_hora_fim > p_data_inicio);
  END IF;
  
  RETURN v_conflito_count > 0;
END;
$$;

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
  -- Verifica se a sala está ativa e não foi soft deleted
  SELECT ativa INTO v_sala_ativa FROM tb_salas WHERE id = p_sala_id AND deleted_at IS NULL;
  
  IF NOT v_sala_ativa THEN
    RETURN FALSE;
  END IF;
  
  -- Verifica se há conflito
  SELECT fn_verificar_conflito_agendamento(p_sala_id, p_data_inicio, p_data_fim) INTO v_conflito;
  
  RETURN NOT v_conflito;
END;
$$;



--Verificar e recriar o trigger de crédito do caixa
DROP TRIGGER IF EXISTS tr_transacao_confirmada_credito ON tb_transacoes;

CREATE OR REPLACE FUNCTION tr_creditar_caixa_ao_confirmar_transacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_setor_id BIGINT;
    v_agendamento_id BIGINT;
    v_valor NUMERIC(14,2);
    v_deve_creditar BOOLEAN := FALSE;
    v_operacao VARCHAR(10);
BEGIN
    -- Determina a operação baseada no tipo de transação
    IF NEW.tipo = 'REEMBOLSO' THEN
        v_operacao := 'DEBITAR';
    ELSE
        v_operacao := 'CREDITAR';
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.status = 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL', 'REEMBOLSO') THEN
            v_deve_creditar := TRUE;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.status = 'CONFIRMADA' AND OLD.status != 'CONFIRMADA' AND NEW.tipo IN ('SINAL', 'PAGAMENTO_FINAL', 'REEMBOLSO') THEN
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
        
        IF v_operacao = 'CREDITAR' THEN
            UPDATE tb_setores SET caixa = caixa + v_valor WHERE id = v_setor_id;
        ELSE -- DEBITAR (para REEMBOLSO)
            UPDATE tb_setores SET caixa = caixa - v_valor WHERE id = v_setor_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

-- Recriar o trigger
CREATE TRIGGER tr_transacao_confirmada_credito
  AFTER INSERT OR UPDATE ON tb_transacoes
  FOR EACH ROW
  EXECUTE FUNCTION tr_creditar_caixa_ao_confirmar_transacao();

CREATE OR REPLACE PROCEDURE pr_confirmar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_pode_confirmar BOOLEAN;
        v_valor_sinal NUMERIC(14,2);
        v_sinal_existente INTEGER;
BEGIN
  -- Validações básicas
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  SELECT fn_validar_confirmacao_agendamento(p_agendamento_id) INTO v_pode_confirmar;
  IF NOT v_pode_confirmar THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser confirmado', p_agendamento_id; 
  END IF;

  -- Atualiza o agendamento (trigger vai atualizar timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'CONFIRMADO'
  WHERE id = p_agendamento_id;

  SELECT valor_sinal INTO v_valor_sinal FROM tb_agendamentos WHERE id = p_agendamento_id;

  -- Evita duplicidade: verifica se já existe um SINAL confirmado para este agendamento
  SELECT COUNT(*) INTO v_sinal_existente
  FROM tb_transacoes 
  WHERE agendamento_id = p_agendamento_id 
    AND tipo = 'SINAL' 
    AND status = 'CONFIRMADA';

  IF COALESCE(v_sinal_existente, 0) = 0 THEN
    -- Insere transação de SINAL já como CONFIRMADA (dispara trigger de crédito)
    INSERT INTO tb_transacoes(
      agendamento_id, valor, tipo, descricao, metodo_pagamento, status
    ) VALUES (
      p_agendamento_id, v_valor_sinal, 'SINAL', 'Sinal creditado na confirmação do agendamento', 'SISTEMA', 'CONFIRMADA'
    );
  END IF;
END;
$$;
