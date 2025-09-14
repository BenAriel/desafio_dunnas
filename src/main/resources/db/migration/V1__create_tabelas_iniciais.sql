CREATE TABLE IF NOT EXISTS tb_cargos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tb_usuarios (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(180) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    role_id BIGINT NOT NULL REFERENCES tb_cargos(id)
);

CREATE TABLE IF NOT EXISTS tb_setores (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    caixa NUMERIC(14,2) NOT NULL DEFAULT 0,
    aberto BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS tb_administradores (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL UNIQUE REFERENCES tb_usuarios(id),
    matricula VARCHAR(20) NOT NULL UNIQUE,
    cpf VARCHAR(11) UNIQUE
);

CREATE TABLE IF NOT EXISTS tb_recepcionistas (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL UNIQUE REFERENCES tb_usuarios(id),
    setor_id BIGINT NOT NULL REFERENCES tb_setores(id),
    matricula VARCHAR(20) NOT NULL UNIQUE,
    cpf VARCHAR(11) UNIQUE
);

-- cada setor deve ter no máximo um recepcionista (exigência de exclusividade)
CREATE UNIQUE INDEX IF NOT EXISTS ux_recepcionista_setor ON tb_recepcionistas(setor_id);

CREATE TABLE IF NOT EXISTS tb_clientes (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL UNIQUE REFERENCES tb_usuarios(id),
    telefone VARCHAR(11) UNIQUE,
    profissao VARCHAR(50)
);