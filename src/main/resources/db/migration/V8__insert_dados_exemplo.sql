
-- Inserir setores de exemplo
INSERT INTO tb_setores (nome, caixa, aberto) VALUES 
('Setor A - Salas de Reunião', 0.00, false),
('Setor B - Salas de Eventos', 0.00, false),
('Setor C - Salas de Treinamento', 0.00, false)
ON CONFLICT DO NOTHING;

-- Inserir salas de exemplo
INSERT INTO tb_salas (nome, valor_aluguel, capacidade_maxima, setor_id, ativa) VALUES 
-- Setor A
('Sala A1 - Pequena', 50.00, 4, (SELECT id FROM tb_setores WHERE nome = 'Setor A - Salas de Reunião'), true),
('Sala A2 - Média', 80.00, 8, (SELECT id FROM tb_setores WHERE nome = 'Setor A - Salas de Reunião'), true),
('Sala A3 - Grande', 120.00, 12, (SELECT id FROM tb_setores WHERE nome = 'Setor A - Salas de Reunião'), true),

-- Setor B
('Sala B1 - Eventos Pequenos', 150.00, 20, (SELECT id FROM tb_setores WHERE nome = 'Setor B - Salas de Eventos'), true),
('Sala B2 - Eventos Médios', 250.00, 40, (SELECT id FROM tb_setores WHERE nome = 'Setor B - Salas de Eventos'), true),
('Sala B3 - Eventos Grandes', 400.00, 80, (SELECT id FROM tb_setores WHERE nome = 'Setor B - Salas de Eventos'), true),

-- Setor C
('Sala C1 - Treinamento Básico', 100.00, 15, (SELECT id FROM tb_setores WHERE nome = 'Setor C - Salas de Treinamento'), true),
('Sala C2 - Treinamento Avançado', 180.00, 25, (SELECT id FROM tb_setores WHERE nome = 'Setor C - Salas de Treinamento'), true),
('Sala C3 - Workshop', 220.00, 30, (SELECT id FROM tb_setores WHERE nome = 'Setor C - Salas de Treinamento'), true)
ON CONFLICT DO NOTHING;

-- Inserir recepcionistas de exemplo
DO $$
DECLARE v_setor_a_id BIGINT;
        v_setor_b_id BIGINT;
        v_setor_c_id BIGINT;
        v_role_recepcionista_id BIGINT;
BEGIN
  -- Obter IDs dos setores
  SELECT id INTO v_setor_a_id FROM tb_setores WHERE nome = 'Setor A - Salas de Reunião';
  SELECT id INTO v_setor_b_id FROM tb_setores WHERE nome = 'Setor B - Salas de Eventos';
  SELECT id INTO v_setor_c_id FROM tb_setores WHERE nome = 'Setor C - Salas de Treinamento';
  
  -- Obter ID do cargo recepcionista
  SELECT id INTO v_role_recepcionista_id FROM tb_cargos WHERE nome = 'ROLE_RECEPCIONISTA';

  -- Inserir usuários recepcionistas
  INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id) VALUES 
  ('Maria Silva', 'maria.silva@empresa.com', crypt('recepcionista123', gen_salt('bf',10)), true, v_role_recepcionista_id),
  ('João Santos', 'joao.santos@empresa.com', crypt('recepcionista123', gen_salt('bf',10)), true, v_role_recepcionista_id),
  ('Ana Costa', 'ana.costa@empresa.com', crypt('recepcionista123', gen_salt('bf',10)), true, v_role_recepcionista_id)
  ON CONFLICT (email) DO NOTHING;

  -- Inserir recepcionistas
  INSERT INTO tb_recepcionistas (usuario_id, setor_id, matricula, cpf) VALUES 
  ((SELECT id FROM tb_usuarios WHERE email = 'maria.silva@empresa.com'), v_setor_a_id, 'REC-0001', '12345678901'),
  ((SELECT id FROM tb_usuarios WHERE email = 'joao.santos@empresa.com'), v_setor_b_id, 'REC-0002', '12345678902'),
  ((SELECT id FROM tb_usuarios WHERE email = 'ana.costa@empresa.com'), v_setor_c_id, 'REC-0003', '12345678903')
  ON CONFLICT (matricula) DO NOTHING;
END $$;

-- Inserir clientes de exemplo
DO $$
DECLARE v_role_cliente_id BIGINT;
BEGIN
  -- Obter ID do cargo cliente
  SELECT id INTO v_role_cliente_id FROM tb_cargos WHERE nome = 'ROLE_CLIENTE';

  -- Inserir usuários clientes
  INSERT INTO tb_usuarios (nome, email, senha, ativo, role_id) VALUES 
  ('Carlos Oliveira', 'carlos.oliveira@email.com', crypt('cliente123', gen_salt('bf',10)), true, v_role_cliente_id),
  ('Fernanda Lima', 'fernanda.lima@email.com', crypt('cliente123', gen_salt('bf',10)), true, v_role_cliente_id),
  ('Roberto Alves', 'roberto.alves@email.com', crypt('cliente123', gen_salt('bf',10)), true, v_role_cliente_id),
  ('Patricia Souza', 'patricia.souza@email.com', crypt('cliente123', gen_salt('bf',10)), true, v_role_cliente_id)
  ON CONFLICT (email) DO NOTHING;

  -- Inserir clientes
  INSERT INTO tb_clientes (usuario_id, telefone, profissao) VALUES 
  ((SELECT id FROM tb_usuarios WHERE email = 'carlos.oliveira@email.com'), '11987654321', 'Empresário'),
  ((SELECT id FROM tb_usuarios WHERE email = 'fernanda.lima@email.com'), '11987654322', 'Consultora'),
  ((SELECT id FROM tb_usuarios WHERE email = 'roberto.alves@email.com'), '11987654323', 'Gerente'),
  ((SELECT id FROM tb_usuarios WHERE email = 'patricia.souza@email.com'), '11987654324', 'Coordenadora')
  ON CONFLICT (telefone) DO NOTHING;
END $$;
