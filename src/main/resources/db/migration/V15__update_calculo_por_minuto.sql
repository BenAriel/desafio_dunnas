
-- Substitui a function de cálculo total para usar minutos proporcionais
CREATE OR REPLACE FUNCTION fn_calcular_valor_total_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_minutos NUMERIC(14,6);
        v_total   NUMERIC(14,6);
BEGIN
  IF p_data_fim <= p_data_inicio THEN
    RETURN 0;
  END IF;

  -- diferença em minutos (com fração)
  v_minutos := EXTRACT(EPOCH FROM (p_data_fim - p_data_inicio)) / 60.0;

  -- total proporcional por minuto (valor_por_hora / 60 * minutos)
  v_total := (p_valor_por_hora / 60.0) * v_minutos;

  -- arredonda para 2 casas
  RETURN ROUND(v_total, 2);
END;
$$;

-- Substitui a function de calcular valor do sinal (50% do total por minuto)
CREATE OR REPLACE FUNCTION fn_calcular_valor_sinal_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_valor_total NUMERIC(14,2);
BEGIN
  v_valor_total := fn_calcular_valor_total_por_horas(p_valor_por_hora, p_data_inicio, p_data_fim);
  RETURN ROUND(v_valor_total * 0.5, 2);
END;
$$;

-- Substitui a function de calcular valor restante
CREATE OR REPLACE FUNCTION fn_calcular_valor_restante_por_horas(
  p_valor_por_hora NUMERIC(14,2),
  p_data_inicio TIMESTAMP,
  p_data_fim TIMESTAMP,
  p_valor_sinal NUMERIC(14,2)
)
RETURNS NUMERIC(14,2)
LANGUAGE plpgsql
AS $$
DECLARE v_valor_total NUMERIC(14,2);
BEGIN
  v_valor_total := fn_calcular_valor_total_por_horas(p_valor_por_hora, p_data_inicio, p_data_fim);
  RETURN ROUND(v_valor_total - p_valor_sinal, 2);
END;
$$;


