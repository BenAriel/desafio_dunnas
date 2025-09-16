

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

  -- Verifica se o agendamento existe
  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_agendamento_exists;
  IF NOT v_agendamento_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  -- Usa function para validar se pode ser confirmado (inclui checagem de início > now)
  SELECT fn_validar_confirmacao_agendamento(p_agendamento_id) INTO v_pode_confirmar;
  IF NOT v_pode_confirmar THEN 
    RAISE EXCEPTION 'Agendamento % não pode ser confirmado', p_agendamento_id; 
  END IF;

  -- Atualiza o agendamento (trigger vai atualizar timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'CONFIRMADO'
  WHERE id = p_agendamento_id;

  -- Obtém valor do sinal do agendamento
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


