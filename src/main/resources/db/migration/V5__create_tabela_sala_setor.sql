CREATE TABLE IF NOT EXISTS tb_salas (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    valor_aluguel NUMERIC(14,2) NOT NULL,
    capacidade_maxima INTEGER NOT NULL,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    setor_id BIGINT NOT NULL REFERENCES tb_setores(id)
);

-- Índice para garantir que não haja salas com o mesmo nome no mesmo setor
CREATE UNIQUE INDEX IF NOT EXISTS ux_sala_nome_setor ON tb_salas(nome, setor_id);

-- Índice para consultas por setor
CREATE INDEX IF NOT EXISTS ix_sala_setor_id ON tb_salas(setor_id);

-- Índice para consultas de salas ativas
CREATE INDEX IF NOT EXISTS ix_sala_ativa ON tb_salas(ativa);

-- Procedure para criar sala
CREATE OR REPLACE PROCEDURE pr_create_sala(
  IN p_nome VARCHAR(100),
  IN p_valor_aluguel NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_setor_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_setor_exists BOOLEAN;
BEGIN
  -- Validações básicas
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_aluguel IS NULL OR p_valor_aluguel <= 0 THEN RAISE EXCEPTION 'Valor do aluguel deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;
  IF p_setor_id IS NULL THEN RAISE EXCEPTION 'Setor é obrigatório'; END IF;

  -- Verifica se o setor existe
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE id = p_setor_id) INTO v_setor_exists;
  IF NOT v_setor_exists THEN RAISE EXCEPTION 'Setor % não encontrado', p_setor_id; END IF;

  -- Verifica se já existe sala com o mesmo nome no setor
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = p_setor_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, p_setor_id;
  END IF;

  -- Insere a sala
  INSERT INTO tb_salas (nome, valor_aluguel, capacidade_maxima, setor_id, ativa)
  VALUES (p_nome, p_valor_aluguel, p_capacidade_maxima, p_setor_id, TRUE);
END;
$$;

-- Procedure para atualizar sala
CREATE OR REPLACE PROCEDURE pr_update_sala(
  IN p_sala_id BIGINT,
  IN p_nome VARCHAR(100),
  IN p_valor_aluguel NUMERIC(14,2),
  IN p_capacidade_maxima INTEGER,
  IN p_ativa BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_sala_exists BOOLEAN;
        v_setor_id BIGINT;
BEGIN
  -- Validações básicas
  IF p_sala_id IS NULL THEN RAISE EXCEPTION 'ID da sala é obrigatório'; END IF;
  IF p_nome IS NULL OR trim(p_nome) = '' THEN RAISE EXCEPTION 'Nome da sala é obrigatório'; END IF;
  IF p_valor_aluguel IS NULL OR p_valor_aluguel <= 0 THEN RAISE EXCEPTION 'Valor do aluguel deve ser maior que zero'; END IF;
  IF p_capacidade_maxima IS NULL OR p_capacidade_maxima <= 0 THEN RAISE EXCEPTION 'Capacidade máxima deve ser maior que zero'; END IF;

  -- Verifica se a sala existe
  SELECT EXISTS(SELECT 1 FROM tb_salas WHERE id = p_sala_id) INTO v_sala_exists;
  IF NOT v_sala_exists THEN RAISE EXCEPTION 'Sala % não encontrada', p_sala_id; END IF;

  -- Obtém o setor_id da sala
  SELECT setor_id INTO v_setor_id FROM tb_salas WHERE id = p_sala_id;

  -- Verifica se já existe outra sala com o mesmo nome no mesmo setor
  IF EXISTS(SELECT 1 FROM tb_salas WHERE nome = p_nome AND setor_id = v_setor_id AND id != p_sala_id) THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', p_nome, v_setor_id;
  END IF;

  -- Atualiza a sala
  UPDATE tb_salas 
  SET nome = p_nome, 
      valor_aluguel = p_valor_aluguel, 
      capacidade_maxima = p_capacidade_maxima,
      ativa = COALESCE(p_ativa, ativa)
  WHERE id = p_sala_id;
END;
$$;


CREATE OR REPLACE PROCEDURE pr_create_setor(
  IN p_nome VARCHAR(100),
  IN p_caixa NUMERIC(14,2),
  IN p_aberto BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_exists BOOLEAN;
BEGIN
  -- Validações
  IF p_nome IS NULL OR trim(p_nome) = '' THEN
    RAISE EXCEPTION 'Nome do setor é obrigatório';
  END IF;
  IF p_caixa IS NULL OR p_caixa < 0 THEN
    RAISE EXCEPTION 'Caixa deve ser >= 0';
  END IF;

  -- Verifica unicidade do nome
  SELECT EXISTS(SELECT 1 FROM tb_setores WHERE nome = p_nome) INTO v_exists;
  IF v_exists THEN
    RAISE EXCEPTION 'Já existe um setor com o nome "%"', p_nome;
  END IF;

  INSERT INTO tb_setores (nome, caixa, aberto)
  VALUES (p_nome, p_caixa, COALESCE(p_aberto, FALSE));
END;
$$;
