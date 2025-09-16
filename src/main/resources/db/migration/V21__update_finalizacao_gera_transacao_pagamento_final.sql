-- Ao finalizar um agendamento, registrar uma transação de PAGAMENTO_FINAL CONFIRMADA
-- com o valor restante

CREATE OR REPLACE PROCEDURE pr_finalizar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_agendamento_exists BOOLEAN;
        v_pode_finalizar BOOLEAN;
        v_valor_restante NUMERIC(14,2);
        v_pf_existente INTEGER;
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

  -- Captura valor restante antes da atualização
  SELECT valor_restante INTO v_valor_restante FROM tb_agendamentos WHERE id = p_agendamento_id;

  -- Atualiza o agendamento (triggers atualizam caixa e timestamp automaticamente)
  UPDATE tb_agendamentos 
  SET status = 'FINALIZADO'
  WHERE id = p_agendamento_id;

  -- Verifica se já existe pagamento final confirmado
  SELECT COUNT(*) INTO v_pf_existente
  FROM tb_transacoes 
  WHERE agendamento_id = p_agendamento_id 
    AND tipo = 'PAGAMENTO_FINAL' 
    AND status = 'CONFIRMADA';

  IF COALESCE(v_pf_existente, 0) = 0 THEN
    -- Insere a transação de pagamento final como CONFIRMADA
    INSERT INTO tb_transacoes (
      agendamento_id, valor, tipo, descricao, metodo_pagamento, status
    ) VALUES (
      p_agendamento_id, v_valor_restante, 'PAGAMENTO_FINAL', 'Pagamento final creditado na finalização do agendamento', 'SISTEMA', 'CONFIRMADA'
    );
  END IF;
END;
$$;
