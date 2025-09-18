
CREATE OR REPLACE PROCEDURE pr_create_usuario_e_administrador(
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_matricula VARCHAR(20),
  IN p_cpf VARCHAR(11)
)
LANGUAGE plpgsql
AS $$
DECLARE v_role_admin_id BIGINT;
        v_usuario_id BIGINT;
BEGIN
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;
  IF p_senha IS NULL OR trim(p_senha) = '' THEN RAISE EXCEPTION 'Senha (hash) é obrigatória'; END IF;
  IF p_matricula IS NULL OR trim(p_matricula) = '' THEN RAISE EXCEPTION 'Matrícula é obrigatória'; END IF;

  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  IF p_cpf IS NULL OR trim(p_cpf) = '' THEN RAISE EXCEPTION 'CPF é obrigatório'; END IF;
  IF length(p_cpf) <> 11 OR p_cpf !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CPF deve ter 11 dígitos numéricos'; END IF;
  IF EXISTS(SELECT 1 FROM tb_administradores WHERE cpf = p_cpf) THEN
    RAISE EXCEPTION 'CPF já cadastrado (%)', p_cpf;
  END IF;
  IF EXISTS(SELECT 1 FROM tb_administradores WHERE matricula = p_matricula) THEN
    RAISE EXCEPTION 'Matrícula já cadastrada (%)', p_matricula;
  END IF;

  SELECT id INTO v_role_admin_id FROM tb_cargos WHERE nome = 'ROLE_ADMIN';
  IF v_role_admin_id IS NULL THEN RAISE EXCEPTION 'Cargo ROLE_ADMIN não encontrado'; END IF;

  INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id)
  VALUES (p_nome, p_email, p_senha, TRUE, v_role_admin_id)
  RETURNING id INTO v_usuario_id;

  INSERT INTO tb_administradores (usuario_id, matricula, cpf)
  VALUES (v_usuario_id, p_matricula, p_cpf);
END;
$$;


CREATE OR REPLACE PROCEDURE pr_create_usuario_e_recepcionista(
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_setor_id BIGINT,
  IN p_matricula VARCHAR(20),
  IN p_cpf VARCHAR(11)
)
LANGUAGE plpgsql
AS $$
DECLARE v_role_recepcionista_id BIGINT; 
        v_exists BOOLEAN;
        v_usuario_id BIGINT;
BEGIN
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;
  IF p_senha IS NULL OR trim(p_senha) = '' THEN RAISE EXCEPTION 'Senha (hash) é obrigatória'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;
  IF p_matricula IS NULL OR trim(p_matricula) = '' THEN RAISE EXCEPTION 'Matrícula é obrigatória'; END IF;

  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  IF p_cpf IS NULL OR trim(p_cpf) = '' THEN RAISE EXCEPTION 'CPF é obrigatório'; END IF;
  IF length(p_cpf) <> 11 OR p_cpf !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CPF deve ter 11 dígitos numéricos'; END IF;
  IF EXISTS(SELECT 1 FROM tb_recepcionistas WHERE cpf = p_cpf) THEN
    RAISE EXCEPTION 'CPF já cadastrado (%)', p_cpf;
  END IF;
  IF EXISTS(SELECT 1 FROM tb_recepcionistas WHERE matricula = p_matricula) THEN
    RAISE EXCEPTION 'Matrícula já cadastrada (%)', p_matricula;
  END IF;

  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_exists;
  IF NOT v_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;
  IF EXISTS(SELECT 1 FROM tb_recepcionistas WHERE setor_id = p_setor_id) THEN
    RAISE EXCEPTION 'Setor % já possui recepcionista alocado', p_setor_id;
  END IF;

  SELECT id INTO v_role_recepcionista_id FROM tb_cargos WHERE nome = 'ROLE_RECEPCIONISTA';
  IF v_role_recepcionista_id IS NULL THEN RAISE EXCEPTION 'Cargo ROLE_RECEPCIONISTA não encontrado'; END IF;

  INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id)
  VALUES (p_nome, p_email, p_senha, TRUE, v_role_recepcionista_id)
  RETURNING id INTO v_usuario_id;

  INSERT INTO tb_recepcionistas (usuario_id, setor_id, matricula, cpf)
  VALUES (v_usuario_id, p_setor_id, p_matricula, p_cpf);
END;
$$;

CREATE OR REPLACE PROCEDURE pr_create_usuario_e_cliente(
  IN p_nome VARCHAR(100),
  IN p_email VARCHAR(180),
  IN p_senha VARCHAR(255),
  IN p_telefone VARCHAR(11),
  IN p_profissao VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE v_role_cliente_id BIGINT;
        v_usuario_id BIGINT;
BEGIN
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome é obrigatório'; END IF;
  IF p_email IS NULL OR trim(p_email) = '' THEN RAISE EXCEPTION 'Email é obrigatório'; END IF;
  IF p_senha IS NULL OR trim(p_senha) = '' THEN RAISE EXCEPTION 'Senha (hash) é obrigatória'; END IF;

  IF EXISTS(SELECT 1 FROM tb_usuarios WHERE email = p_email) THEN
    RAISE EXCEPTION 'Email já cadastrado (%)', p_email;
  END IF;
  IF p_telefone IS NULL OR trim(p_telefone) = '' THEN RAISE EXCEPTION 'Telefone é obrigatório'; END IF;
  IF length(p_telefone) <> 11 OR p_telefone !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'Telefone deve ter 11 dígitos numéricos'; END IF;
  IF EXISTS(SELECT 1 FROM tb_clientes WHERE telefone = p_telefone) THEN
    RAISE EXCEPTION 'Telefone já cadastrado (%)', p_telefone;
  END IF;

  SELECT id INTO v_role_cliente_id FROM tb_cargos WHERE nome = 'ROLE_CLIENTE';
  IF v_role_cliente_id IS NULL THEN RAISE EXCEPTION 'Cargo ROLE_CLIENTE não encontrado'; END IF;

  INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id)
  VALUES (p_nome, p_email, p_senha, TRUE, v_role_cliente_id)
  RETURNING id INTO v_usuario_id;

  INSERT INTO tb_clientes (usuario_id, telefone, profissao)
  VALUES (v_usuario_id, p_telefone, p_profissao);
END;
$$;
