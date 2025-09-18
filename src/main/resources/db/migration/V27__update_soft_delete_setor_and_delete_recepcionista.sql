-- Atualiza pr_soft_delete_setor para também soft-deletar todas as salas do setor
CREATE OR REPLACE PROCEDURE pr_soft_delete_setor(
  IN p_setor_id BIGINT,
  IN p_deleted_by BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
        v_agendamentos_ativos INTEGER;
        v_recepcionista_id BIGINT;
        v_sala_id BIGINT;
BEGIN
  -- Validações básicas
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;

  -- Verifica se o setor existe e não está soft deleted
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id AND deleted_at IS NULL) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado ou já foi excluído', p_setor_id; END IF;

  -- Verifica se há agendamentos ativos em salas deste setor
  SELECT COUNT(*) INTO v_agendamentos_ativos
  FROM tb_agendamentos a
  JOIN tb_salas s ON s.id = a.sala_id
  WHERE s.setor_id = p_setor_id 
    AND a.status IN ('SOLICITADO', 'CONFIRMADO');

  IF v_agendamentos_ativos > 0 THEN
    RAISE EXCEPTION 'Não é possível excluir o setor. Existem % agendamentos ativos em salas deste setor', v_agendamentos_ativos;
  END IF;

  -- Desassocia recepcionista, se houver
  SELECT id INTO v_recepcionista_id
  FROM tb_recepcionistas 
  WHERE setor_id = p_setor_id
  LIMIT 1;

  IF v_recepcionista_id IS NOT NULL THEN
    UPDATE tb_recepcionistas 
    SET setor_id = NULL
    WHERE id = v_recepcionista_id;
  END IF;

  -- Soft delete do setor
  UPDATE tb_setores 
  SET deleted_at = CURRENT_TIMESTAMP,
      deleted_by = p_deleted_by
  WHERE id = p_setor_id;

  -- Soft delete de todas as salas do setor (que não estejam soft-deletadas)
  FOR v_sala_id IN SELECT id FROM tb_salas WHERE setor_id = p_setor_id AND deleted_at IS NULL LOOP
    CALL pr_soft_delete_sala(v_sala_id, p_deleted_by);
  END LOOP;
END;
$$;

-- Cria procedure para excluir recepcionista garantindo fechamento do setor se aberto
CREATE OR REPLACE PROCEDURE pr_delete_recepcionista(
  IN p_recepcionista_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_exists BOOLEAN;
        v_setor_id BIGINT;
        v_setor_aberto BOOLEAN;
BEGIN
  IF p_recepcionista_id IS NULL THEN RAISE EXCEPTION 'ID do recepcionista é obrigatório'; END IF;

  SELECT EXISTS(SELECT 1 FROM tb_recepcionistas WHERE id = p_recepcionista_id) INTO v_exists;
  IF NOT v_exists THEN RAISE EXCEPTION 'Recepcionista % não encontrado', p_recepcionista_id; END IF;

  SELECT setor_id INTO v_setor_id FROM tb_recepcionistas WHERE id = p_recepcionista_id;

  IF v_setor_id IS NOT NULL THEN
    SELECT aberto INTO v_setor_aberto FROM tb_setores WHERE id = v_setor_id;
    IF v_setor_aberto THEN
      -- Fecha setor utilizando a procedure de fechamento (valida condições internamente)
      CALL pr_fechar_setor(v_setor_id);
    END IF;
  END IF;

  -- Exclui o recepcionista
  DELETE FROM tb_recepcionistas WHERE id = p_recepcionista_id;
END;
$$;