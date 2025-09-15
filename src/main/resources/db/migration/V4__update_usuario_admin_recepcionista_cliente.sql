
-- Atualizar Usuário + Administrador
CREATE OR REPLACE PROCEDURE pr_update_usuario_e_administrador(
  IN p_usuario_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_matricula VARCHAR(20),
  IN p_cpf VARCHAR(11)
)
LANGUAGE plpgsql
AS $$
DECLARE v_admin_id BIGINT;
BEGIN
  -- Validações básicas
  IF p_usuario_id IS NULL THEN RAISE EXCEPTION 'ID do usuário é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;
  IF p_matricula IS NULL OR trim(p_matricula) = '' THEN RAISE EXCEPTION 'Matrícula é obrigatória'; END IF;

  -- Verifica se existe
  IF NOT EXISTS(SELECT 1 FROM tb_usuarios WHERE id = p_usuario_id) THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  SELECT id INTO v_admin_id FROM tb_administradores WHERE usuario_id = p_usuario_id;
  IF v_admin_id IS NULL THEN RAISE EXCEPTION 'Administrador não encontrado para usuário'; END IF;

  -- Atualiza usuário
  UPDATE tb_usuarios SET nome = p_nome, email = p_email,
    senha = COALESCE(p_senha, senha)
  WHERE id = p_usuario_id;

  -- Atualiza administrador
  UPDATE tb_administradores SET matricula = p_matricula, cpf = p_cpf
  WHERE id = v_admin_id;
END;
$$;

-- Atualizar Usuário + Recepcionista
CREATE OR REPLACE PROCEDURE pr_update_usuario_e_recepcionista(
  IN p_usuario_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_setor_id BIGINT,
  IN p_matricula VARCHAR(20),
  IN p_cpf VARCHAR(11)
)
LANGUAGE plpgsql
AS $$
DECLARE v_recepcionista_id BIGINT;
BEGIN
  IF p_usuario_id IS NULL THEN RAISE EXCEPTION 'ID do usuário é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;
  IF p_matricula IS NULL OR trim(p_matricula) = '' THEN RAISE EXCEPTION 'Matrícula é obrigatória'; END IF;

  IF NOT EXISTS(SELECT 1 FROM tb_usuarios WHERE id = p_usuario_id) THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  SELECT id INTO v_recepcionista_id FROM tb_recepcionistas WHERE usuario_id = p_usuario_id;
  IF v_recepcionista_id IS NULL THEN RAISE EXCEPTION 'Recepcionista não encontrado para usuário'; END IF;

  UPDATE tb_usuarios SET nome = p_nome, email = p_email,
    senha = COALESCE(p_senha, senha)
  WHERE id = p_usuario_id;

  UPDATE tb_recepcionistas SET setor_id = p_setor_id, matricula = p_matricula, cpf = p_cpf
  WHERE id = v_recepcionista_id;
END;
$$;

-- Atualizar Usuário + Cliente
CREATE OR REPLACE PROCEDURE pr_update_usuario_e_cliente(
  IN p_usuario_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_telefone VARCHAR(11),
  IN p_profissao VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE v_cliente_id BIGINT;
BEGIN
  IF p_usuario_id IS NULL THEN RAISE EXCEPTION 'ID do usuário é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;

  IF NOT EXISTS(SELECT 1 FROM tb_usuarios WHERE id = p_usuario_id) THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  SELECT id INTO v_cliente_id FROM tb_clientes WHERE usuario_id = p_usuario_id;
  IF v_cliente_id IS NULL THEN RAISE EXCEPTION 'Cliente não encontrado para usuário'; END IF;

  UPDATE tb_usuarios SET nome = p_nome, email = p_email,
    senha = COALESCE(p_senha, senha)
  WHERE id = p_usuario_id;

  UPDATE tb_clientes SET telefone = p_telefone, profissao = p_profissao
  WHERE id = v_cliente_id;
END;
$$;

