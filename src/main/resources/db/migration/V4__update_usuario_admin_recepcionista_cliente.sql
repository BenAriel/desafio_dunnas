
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
  IF p_cpf IS NULL OR trim(p_cpf) = '' THEN RAISE EXCEPTION 'CPF é obrigatório'; END IF;
  IF length(p_cpf) <> 11 OR p_cpf !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CPF deve ter 11 dígitos numéricos'; END IF;

  -- Verifica se existe
  IF NOT EXISTS(SELECT 1 FROM tb_usuarios WHERE id = p_usuario_id) THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  -- Unicidade de e-mail (excluindo o próprio usuário)
  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email AND id <> p_usuario_id) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  SELECT id INTO v_admin_id FROM tb_administradores WHERE usuario_id = p_usuario_id;
  IF v_admin_id IS NULL THEN RAISE EXCEPTION 'Administrador não encontrado para usuário'; END IF;
  -- Unicidade de CPF do administrador (excluindo o próprio registro)
  IF EXISTS(SELECT 1 FROM tb_administradores WHERE cpf = p_cpf AND id <> v_admin_id) THEN
    RAISE EXCEPTION 'CPF já cadastrado (%)', p_cpf;
  END IF;

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
  IF p_cpf IS NULL OR trim(p_cpf) = '' THEN RAISE EXCEPTION 'CPF é obrigatório'; END IF;
  IF length(p_cpf) <> 11 OR p_cpf !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CPF deve ter 11 dígitos numéricos'; END IF;

  IF NOT EXISTS(SELECT 1 FROM tb_usuarios WHERE id = p_usuario_id) THEN
    RAISE EXCEPTION 'Usuário não encontrado';
  END IF;
  -- Unicidade de e-mail (excluindo o próprio usuário)
  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email AND id <> p_usuario_id) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  SELECT id INTO v_recepcionista_id FROM tb_recepcionistas WHERE usuario_id = p_usuario_id;
  IF v_recepcionista_id IS NULL THEN RAISE EXCEPTION 'Recepcionista não encontrado para usuário'; END IF;
  -- Unicidade de CPF do recepcionista (excluindo o próprio)
  IF EXISTS(SELECT 1 FROM tb_recepcionistas WHERE cpf = p_cpf AND id <> v_recepcionista_id) THEN
    RAISE EXCEPTION 'CPF já cadastrado (%)', p_cpf;
  END IF;
  -- Setor não pode estar alocado para outro recepcionista
  IF EXISTS(SELECT 1 FROM tb_recepcionistas WHERE setor_id = p_setor_id AND id <> v_recepcionista_id) THEN
    RAISE EXCEPTION 'Setor % já possui recepcionista alocado', p_setor_id;
  END IF;

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
  -- Unicidade de e-mail (excluindo o próprio usuário)
  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email AND id <> p_usuario_id) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  SELECT id INTO v_cliente_id FROM tb_clientes WHERE usuario_id = p_usuario_id;
  IF v_cliente_id IS NULL THEN RAISE EXCEPTION 'Cliente não encontrado para usuário'; END IF;

  UPDATE tb_usuarios SET nome = p_nome, email = p_email,
    senha = COALESCE(p_senha, senha)
  WHERE id = p_usuario_id;

  IF p_telefone IS NULL OR trim(p_telefone) = '' THEN RAISE EXCEPTION 'Telefone é obrigatório'; END IF;
  -- Unicidade de telefone (excluindo o próprio)
  IF EXISTS(SELECT 1 FROM tb_clientes WHERE telefone = p_telefone AND id <> v_cliente_id) THEN
    RAISE EXCEPTION 'Telefone já cadastrado (%)', p_telefone;
  END IF;
  IF length(p_telefone) <> 11 OR p_telefone !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'Telefone deve ter 11 dígitos numéricos'; END IF;
  UPDATE tb_clientes SET telefone = p_telefone, profissao = p_profissao
  WHERE id = v_cliente_id;
END;
$$;

