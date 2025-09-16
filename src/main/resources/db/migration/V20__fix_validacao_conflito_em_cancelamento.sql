-- Ajustar validação de conflito para não bloquear cancelamento/recusa
CREATE OR REPLACE FUNCTION tr_validar_conflito_agendamento()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE v_conflito BOOLEAN;
BEGIN
  -- Se o status novo não é CONFIRMADO nem FINALIZADO, não há por que validar conflito
  IF NEW.status NOT IN ('CONFIRMADO', 'FINALIZADO') THEN
    RETURN NEW;
  END IF;

  -- Verifica se há conflito usando a function existente
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


-- Limpeza de triggers/functions redundantes
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.triggers 
    WHERE event_object_table = 'tb_recepcionistas' 
      AND trigger_name = 'tr_recepcionista_setor_unique'
  ) THEN
    EXECUTE 'DROP TRIGGER tr_recepcionista_setor_unique ON tb_recepcionistas';
  END IF;
EXCEPTION WHEN undefined_table THEN NULL; END $$;

DO $$ BEGIN
  PERFORM 1 FROM pg_proc WHERE proname = 'tr_validar_recepcionista_setor';
  IF FOUND THEN
    EXECUTE 'DROP FUNCTION tr_validar_recepcionista_setor()';
  END IF;
END $$;

-- Remover trigger e function: nome de sala único por setor (duplicam ux_sala_nome_setor)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.triggers 
    WHERE event_object_table = 'tb_salas' 
      AND trigger_name = 'tr_sala_nome_setor_unique'
  ) THEN
    EXECUTE 'DROP TRIGGER tr_sala_nome_setor_unique ON tb_salas';
  END IF;
EXCEPTION WHEN undefined_table THEN NULL; END $$;

DO $$ BEGIN
  PERFORM 1 FROM pg_proc WHERE proname = 'tr_validar_nome_sala_setor';
  IF FOUND THEN
    EXECUTE 'DROP FUNCTION tr_validar_nome_sala_setor()';
  END IF;
END $$;

-- Remover function de relatório desatualizada (usa coluna antiga valor_aluguel)
DO $$ BEGIN
  PERFORM 1 FROM pg_proc WHERE proname = 'fn_salas_disponiveis_periodo';
  IF FOUND THEN
    EXECUTE 'DROP FUNCTION fn_salas_disponiveis_periodo(bigint, timestamp, timestamp)';
  END IF;
END $$;
