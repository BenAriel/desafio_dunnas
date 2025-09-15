
-- Trigger para atualizar caixa do setor quando agendamento é finalizado
CREATE OR REPLACE FUNCTION tr_atualizar_caixa_setor_finalizacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_setor_id BIGINT;
        v_valor_restante NUMERIC(14,2);
BEGIN
  -- Só executa se o status mudou para FINALIZADO
  IF NEW.status = 'FINALIZADO' AND OLD.status != 'FINALIZADO' THEN
    -- Obtém o setor da sala
    SELECT setor_id INTO v_setor_id FROM tb_salas WHERE id = NEW.sala_id;
    
    -- Obtém o valor restante
    v_valor_restante := NEW.valor_restante;
    
    -- Atualiza o caixa do setor
    UPDATE tb_setores 
    SET caixa = caixa + v_valor_restante
    WHERE id = v_setor_id;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_agendamento_finalizado
  AFTER UPDATE ON tb_agendamentos
  FOR EACH ROW
  EXECUTE FUNCTION tr_atualizar_caixa_setor_finalizacao();

-- Trigger para registrar histórico de mudanças de status de agendamento
CREATE OR REPLACE FUNCTION tr_registrar_historico_agendamento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Registra mudança de status
  IF OLD.status != NEW.status THEN
    INSERT INTO tb_historico_agendamentos (
      agendamento_id, 
      status_anterior, 
      status_novo, 
      data_mudanca, 
      observacao
    ) VALUES (
      NEW.id,
      OLD.status,
      NEW.status,
      CURRENT_TIMESTAMP,
      'Mudança automática de status via trigger'
    );
  END IF;
  
  RETURN NEW;
END;
$$;

-- Criar tabela de histórico se não existir
CREATE TABLE IF NOT EXISTS tb_historico_agendamentos (
    id BIGSERIAL PRIMARY KEY,
    agendamento_id BIGINT NOT NULL REFERENCES tb_agendamentos(id),
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20) NOT NULL,
    data_mudanca TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observacao VARCHAR(500)
);

CREATE TRIGGER tr_historico_agendamento
  AFTER UPDATE ON tb_agendamentos
  FOR EACH ROW
  EXECUTE FUNCTION tr_registrar_historico_agendamento();

-- Trigger para validar integridade de recepcionista por setor
CREATE OR REPLACE FUNCTION tr_validar_recepcionista_setor()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_count INTEGER;
BEGIN
  -- Verifica se já existe outro recepcionista no mesmo setor
  SELECT COUNT(*) INTO v_count
  FROM tb_recepcionistas 
  WHERE setor_id = NEW.setor_id 
  AND id != COALESCE(NEW.id, 0);
  
  IF v_count > 0 THEN
    RAISE EXCEPTION 'Setor % já possui um recepcionista alocado', NEW.setor_id;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_recepcionista_setor_unique
  BEFORE INSERT OR UPDATE ON tb_recepcionistas
  FOR EACH ROW
  EXECUTE FUNCTION tr_validar_recepcionista_setor();

-- Trigger para validar integridade de nome de sala por setor
CREATE OR REPLACE FUNCTION tr_validar_nome_sala_setor()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_count INTEGER;
BEGIN
  -- Verifica se já existe outra sala com o mesmo nome no mesmo setor
  SELECT COUNT(*) INTO v_count
  FROM tb_salas 
  WHERE nome = NEW.nome 
  AND setor_id = NEW.setor_id
  AND id != COALESCE(NEW.id, 0);
  
  IF v_count > 0 THEN
    RAISE EXCEPTION 'Já existe uma sala com o nome "%" no setor %', NEW.nome, NEW.setor_id;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_sala_nome_setor_unique
  BEFORE INSERT OR UPDATE ON tb_salas
  FOR EACH ROW
  EXECUTE FUNCTION tr_validar_nome_sala_setor();

-- Trigger para atualizar timestamp de modificação em agendamentos
CREATE OR REPLACE FUNCTION tr_atualizar_timestamp_agendamento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Atualiza data de confirmação se status mudou para CONFIRMADO
  IF NEW.status = 'CONFIRMADO' AND OLD.status != 'CONFIRMADO' THEN
    NEW.data_confirmacao := CURRENT_TIMESTAMP;
  END IF;
  
  -- Atualiza data de finalização se status mudou para FINALIZADO
  IF NEW.status = 'FINALIZADO' AND OLD.status != 'FINALIZADO' THEN
    NEW.data_finalizacao := CURRENT_TIMESTAMP;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_timestamp_agendamento
  BEFORE UPDATE ON tb_agendamentos
  FOR EACH ROW
  EXECUTE FUNCTION tr_atualizar_timestamp_agendamento();

-- Trigger para validar conflitos de agendamento antes da inserção/atualização
CREATE OR REPLACE FUNCTION tr_validar_conflito_agendamento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_conflito BOOLEAN;
BEGIN
  -- Verifica se há conflito usando a function
  SELECT fn_verificar_conflito_agendamento(
    NEW.sala_id, 
    NEW.data_hora_inicio, 
    NEW.data_hora_fim, 
    NEW.id
  ) INTO v_conflito;
  
  IF v_conflito THEN
    RAISE EXCEPTION 'Conflito de agendamento: já existe um agendamento confirmado para esta sala no período especificado';
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_validar_conflito_agendamento
  BEFORE INSERT OR UPDATE ON tb_agendamentos
  FOR EACH ROW
  EXECUTE FUNCTION tr_validar_conflito_agendamento();
