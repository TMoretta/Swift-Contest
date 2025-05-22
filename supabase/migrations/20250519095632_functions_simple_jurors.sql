-- CREATE SIMPLE JUROR
CREATE OR REPLACE FUNCTION public.create_simple_juror (
  p_id uuid,
  p_created_at timestamptz,
  p_full_name varchar
)
RETURNS SETOF public.simple_jurors AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.simple_jurors (
      id,
      created_at,
      full_name
    )
    VALUES (
      p_id,
      p_created_at,
      p_full_name
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION public.update_simple_juror (
  p_id uuid,
  p_created_at timestamptz,
  p_full_name varchar
)
RETURNS SETOF public.simple_jurors AS $$
BEGIN
  RETURN QUERY
    UPDATE public.simple_jurors
    SET
      created_at = p_created_at,
      full_name = p_full_name
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION public.delete_simple_juror_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.simple_jurors
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION public.get_simple_juror_by_id(
  p_id uuid
)
RETURNS SETOF public.simple_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.simple_jurors
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;