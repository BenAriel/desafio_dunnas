CREATE TABLE IF NOT EXISTS tb_transacoes (
    id BIGSERIAL PRIMARY KEY,
    agendamento_id BIGINT NOT NULL REFERENCES tb_agendamentos(id),
    valor NUMERIC(14,2) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    data_transacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descricao VARCHAR(200),
    metodo_pagamento VARCHAR(100)
);

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS ix_transacao_agendamento_id ON tb_transacoes(agendamento_id);
CREATE INDEX IF NOT EXISTS ix_transacao_tipo ON tb_transacoes(tipo);
CREATE INDEX IF NOT EXISTS ix_transacao_status ON tb_transacoes(status);
CREATE INDEX IF NOT EXISTS ix_transacao_data ON tb_transacoes(data_transacao);