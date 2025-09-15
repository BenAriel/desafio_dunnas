CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Seeds de cargos
INSERT INTO tb_cargos (nome) VALUES ('ROLE_ADMIN') ON CONFLICT (nome) DO NOTHING;
INSERT INTO tb_cargos (nome) VALUES ('ROLE_RECEPCIONISTA') ON CONFLICT (nome) DO NOTHING;
INSERT INTO tb_cargos (nome) VALUES ('ROLE_CLIENTE') ON CONFLICT (nome) DO NOTHING;

-- Seeds de administrador
DO $$
DECLARE v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM tb_usuarios WHERE email = 'admin@local.test') INTO v_exists;
  IF NOT v_exists THEN
    INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id)
    VALUES ('Admin Padrão', 'admin@local.test', crypt('admin123', gen_salt('bf',10)), (TRUE), (SELECT id FROM tb_cargos WHERE nome='ROLE_ADMIN'));
    INSERT INTO tb_administradores (usuario_id, matricula)
    VALUES ((SELECT id FROM tb_usuarios WHERE email='admin@local.test'), 'ADM-0001');
  END IF;
END $$;