-- Function: validar se agendamento pode ser cancelado (apenas SOLICITADO)
CREATE OR REPLACE FUNCTION fn_validar_cancelamento_agendamento(p_agendamento_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE v_status VARCHAR(20);
BEGIN
  SELECT status INTO v_status FROM tb_agendamentos WHERE id = p_agendamento_id;
  RETURN v_status = 'SOLICITADO';
END;
$$;

-- Procedure: cancelar agendamento (sem efeitos financeiros; sinal não existe ainda)
CREATE OR REPLACE PROCEDURE pr_cancelar_agendamento(
  IN p_agendamento_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_exists BOOLEAN;
        v_pode_cancelar BOOLEAN;
BEGIN
  IF p_agendamento_id IS NULL THEN RAISE EXCEPTION 'ID do agendamento é obrigatório'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_agendamentos WHERE id = p_agendamento_id) INTO v_exists;
  IF NOT v_exists THEN RAISE EXCEPTION 'Agendamento % não encontrado', p_agendamento_id; END IF;

  SELECT fn_validar_cancelamento_agendamento(p_agendamento_id) INTO v_pode_cancelar;
  IF NOT v_pode_cancelar THEN
    RAISE EXCEPTION 'Agendamento % não pode ser cancelado (já confirmado ou finalizado)', p_agendamento_id;
  END IF;

  UPDATE tb_agendamentos
  SET status = 'CANCELADO'
  WHERE id = p_agendamento_id;
  -- tr_historico_agendamento registrará o histórico automaticamente
END;
$$;


