-- CREATE JURATION
CREATE OR REPLACE FUNCTION public.create_juration (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_juror_id uuid,
  p_juror_status public.juror_status
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.jurations (
      id,
      created_at,
      contest_id,
      juror_id,
      juror_status
    )
    VALUES (
      p_id,
      p_created_at,
      p_contest_id,
      p_juror_id,
      p_juror_status
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JURATION BY ID
CREATE OR REPLACE FUNCTION public.update_juration (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_juror_id uuid,
  p_juror_status public.juror_status
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
    UPDATE public.jurations
    SET
      created_at = p_created_at,
      contest_id = p_contest_id,
      juror_id = p_juror_id,
      juror_status = p_juror_status
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JURATION BY ID
CREATE OR REPLACE FUNCTION public.delete_juration_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.jurations
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATION BY ID
CREATE OR REPLACE FUNCTION public.get_juration_by_id(
  p_id uuid
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.jurations
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATION BY CONTEST ID AND JUROR ID
CREATE OR REPLACE FUNCTION public.get_juration_by_contest_id_and_juror_id(
  p_contest_id uuid,
  p_juror_id uuid
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.jurations
    WHERE contest_id = p_contest_id AND juror_id = p_juror_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION public.get_jurations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.jurations
  WHERE contest_id = p_contest_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATIONS BY JUROR ID
CREATE OR REPLACE FUNCTION public.get_jurations_by_juror_id(
  p_juror_id uuid
)
RETURNS SETOF public.jurations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.jurations
  WHERE juror_id = p_juror_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;