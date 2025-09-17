
-- Adicionar colunas de soft delete para tb_salas
ALTER TABLE tb_salas ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;
ALTER TABLE tb_salas ADD COLUMN IF NOT EXISTS deleted_by BIGINT REFERENCES tb_usuarios(id);

-- Adicionar colunas de soft delete para tb_setores  
ALTER TABLE tb_setores ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP;

-- Atualizar procedures de sala para considerar soft delete
CREATE OR REPLACE PROCEDURE pr_create_sala(
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;

  -- Verifica se o setor existe e não está soft deleted
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id AND deleted_at IS NULL) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado ou foi excluído', p_setor_id; END IF;

  -- Verifica se já existe sala com o mesmo nome no setor (não soft deleted)
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = p_setor_id AND deleted_at IS NULL) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, p_setor_id;
  END IF;

  -- Insere a sala
  INSERT INTO tb_salas (nome, valor_por_hora, capacidade_maxima, setor_id, ativa)
  VALUES (p_nome, p_valor_por_hora, p_capacidade_maxima, p_setor_id, TRUE);
END;
$$;

-- Procedure para soft delete de sala
CREATE OR REPLACE PROCEDURE pr_soft_delete_sala(
  IN p_sala_id BIGINT,
  IN p_deleted_by BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_agendamentos_ativos INTEGER;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;

  -- Verifica se a sala existe e não está soft deleted
  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id AND deleted_at IS NULL) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada ou já foi excluída', p_sala_id; END IF;

  -- Verifica se há agendamentos ativos (SOLICITADO ou CONFIRMADO)
  SELECT COUNT(*) INTO v_agendamentos_ativos
  FROM tb_agendamentos a
  WHERE a.sala_id = p_sala_id 
    AND a.status IN ('SOLICITADO', 'CONFIRMADO');

  IF v_agendamentos_ativos > 0 THEN
    RAISE EXCEPTION 'Não é possível excluir a sala. Existem % agendamentos ativos para esta sala', v_agendamentos_ativos;
  END IF;

  -- Soft delete da sala
  UPDATE tb_salas 
  SET deleted_at = CURRENT_TIMESTAMP,
      deleted_by = p_deleted_by
  WHERE id = p_sala_id;
END;
$$;

-- Procedure para soft delete de setor
CREATE OR REPLACE PROCEDURE pr_soft_delete_setor(
  IN p_setor_id BIGINT,
  IN p_deleted_by BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
        v_agendamentos_ativos INTEGER;
        v_recepcionista_id BIGINT;
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

  -- Verifica se há recepcionista ativo no setor
  SELECT id INTO v_recepcionista_id
  FROM tb_recepcionistas 
  WHERE setor_id = p_setor_id;

  IF v_recepcionista_id IS NOT NULL THEN
    -- Remove o recepcionista do setor (seta setor_id para NULL temporariamente)
    UPDATE tb_recepcionistas 
    SET setor_id = NULL
    WHERE id = v_recepcionista_id;
  END IF;

  -- Soft delete do setor
  UPDATE tb_setores 
  SET deleted_at = CURRENT_TIMESTAMP,
      deleted_by = p_deleted_by
  WHERE id = p_setor_id;
END;
$$;

-- talvez seja usado: Procedure para reativar setor (permite reatribuir recepcionista) 
CREATE OR REPLACE PROCEDURE pr_reativar_setor(
  IN p_setor_id BIGINT,
  IN p_reativado_by BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'ID do setor é obrigatório'; END IF;

  -- Verifica se o setor existe e está soft deleted
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id AND deleted_at IS NOT NULL) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado ou não foi excluído', p_setor_id; END IF;

  -- Reativa o setor
  UPDATE tb_setores 
  SET deleted_at = NULL,
      deleted_by = NULL
  WHERE id = p_setor_id;
END;
$$;

-- Atualizar procedures existentes para considerar soft delete
CREATE OR REPLACE PROCEDURE pr_update_sala(
  IN p_sala_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_valor_por_hora NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_ativa BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_setor_id BIGINT;
        v_agendamentos_ativos INTEGER;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_por_hora IS NULL OR p_valor_por_hora <= 0 THEN RAISE EXCEPTION 'Valor por hora deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;

  -- Verifica se a sala existe e não está soft deleted
  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id AND deleted_at IS NULL) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada ou foi excluída', p_sala_id; END IF;

  -- Obtém o setor_id da sala
  SELECT setor_id INTO v_setor_id FROM tb_salas WHERE id = p_sala_id;

  -- Verifica se já existe outra sala com o mesmo nome no mesmo setor (não soft deleted)
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = v_setor_id AND id != p_sala_id AND deleted_at IS NULL) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, v_setor_id;
  END IF;

  -- Se tentando desativar (ativa = false), verifica se há agendamentos ativos
  IF p_ativa = FALSE THEN
    SELECT COUNT(*) INTO v_agendamentos_ativos
    FROM tb_agendamentos a
    WHERE a.sala_id = p_sala_id 
      AND a.status IN ('SOLICITADO', 'CONFIRMADO');

    IF v_agendamentos_ativos > 0 THEN
      RAISE EXCEPTION 'Não é possível desativar a sala. Existem % agendamentos ativos para esta sala', v_agendamentos_ativos;
    END IF;
  END IF;

  -- Atualiza a sala
  UPDATE tb_salas 
  SET nome = p_nome, 
      valor_por_hora = p_valor_por_hora, 
      capacidade_maxima = p_capacidade_maxima,
      ativa = COALESCE(p_ativa, ativa)
  WHERE id = p_sala_id;
END;
$$;

-- Atualizar functions de validação para considerar soft delete
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

-- Atualizar function de conflito para considerar soft delete
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
      AND a.status IN ('CONFIRMADO', 'FINALIZADO');
  ELSE
    -- Verificação para atualização de agendamento existente
    SELECT COUNT(*) INTO v_conflito_count
    FROM tb_agendamentos a
    JOIN tb_salas s ON s.id = a.sala_id
    WHERE a.sala_id = p_sala_id 
      AND s.deleted_at IS NULL  -- sala não soft deleted
      AND a.status IN ('CONFIRMADO', 'FINALIZADO')
      AND a.id != p_agendamento_id;
  END IF;
  
  RETURN v_conflito_count > 0;
END;
$$;
