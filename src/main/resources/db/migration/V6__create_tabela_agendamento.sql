CREATE TABLE IF NOT EXISTS tb_agendamentos (
    id BIGSERIAL PRIMARY KEY,
    sala_id BIGINT NOT NULL REFERENCES tb_salas(id),
    cliente_id BIGINT NOT NULL REFERENCES tb_clientes(id),
    data_hora_inicio TIMESTAMP NOT NULL,
    data_hora_fim TIMESTAMP NOT NULL,
    valor_total NUMERIC(14,2) NOT NULL,
    valor_sinal NUMERIC(14,2) NOT NULL,
    valor_restante NUMERIC(14,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SOLICITADO',
    observacoes VARCHAR(500),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_confirmacao TIMESTAMP,
    data_finalizacao TIMESTAMP
);

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS ix_agendamento_sala_id ON tb_agendamentos(sala_id);
CREATE INDEX IF NOT EXISTS ix_agendamento_cliente_id ON tb_agendamentos(cliente_id);
CREATE INDEX IF NOT EXISTS ix_agendamento_status ON tb_agendamentos(status);
CREATE INDEX IF NOT EXISTS ix_agendamento_data_inicio ON tb_agendamentos(data_hora_inicio);
CREATE INDEX IF NOT EXISTS ix_agendamento_data_fim ON tb_agendamentos(data_hora_fim);

-- Índice composto para verificação de conflitos
CREATE INDEX IF NOT EXISTS ix_agendamento_sala_periodo ON tb_agendamentos(sala_id, data_hora_inicio, data_hora_fim);
