-- CREATE JURATION
CREATE OR REPLACE FUNCTION create_juration (
  p_juration jurations
)
RETURNS jurations AS $$
DECLARE
  v_juration jurations;
BEGIN
  INSERT INTO jurations (
    id,
    created_at,
    contest_id,
    juror_id,
    juror_status
  )
  VALUES (
    p_juration.id,
    p_juration.created_at,
    p_juration.contest_id,
    p_juration.juror_id,
    p_juration.juror_status
  )
  RETURNING * INTO STRICT v_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JURATION BY ID
CREATE OR REPLACE FUNCTION update_juration (
  p_juration jurations
)
RETURNS jurations AS $$
DECLARE
  v_juration jurations;
BEGIN
  -- Verify if the juration exists
  IF NOT EXISTS (SELECT 1 FROM jurations WHERE id = p_juration.id) THEN
    RAISE EXCEPTION 'No juration found';
  END IF;

  UPDATE jurations
  SET
    contest_id = p_juration.contest_id,
    juror_id = p_juration.juror_id,
    juror_status = p_juration.juror_status
  WHERE id = p_juration.id
  RETURNING * INTO STRICT v_juration;

  RETURN v_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JURATION BY ID
CREATE OR REPLACE FUNCTION delete_juration_by_id(
  p_id uuid
)
RETURNS jurations AS $$
DECLARE
  v_juration jurations;
BEGIN
  -- Verify if the juration exists
  IF NOT EXISTS (SELECT 1 FROM jurations WHERE id = p_id) THEN
    RAISE EXCEPTION 'No juration found';
  END IF;

  DELETE FROM jurations
  WHERE id = p_id
  RETURNING * INTO STRICT v_juration;

  RETURN v_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATION BY ID
CREATE OR REPLACE FUNCTION get_juration_by_id(
  p_id uuid
)
RETURNS SETOF jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM jurations
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATION BY CONTEST ID AND JUROR ID
CREATE OR REPLACE FUNCTION get_juration_by_contest_id_and_juror_id(
  p_contest_id uuid,
  p_juror_id uuid
)
RETURNS SETOF jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM jurations
    WHERE contest_id = p_contest_id AND juror_id = p_juror_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION get_jurations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF jurations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM jurations
  WHERE contest_id = p_contest_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the jurations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JURATIONS BY JUROR ID
CREATE OR REPLACE FUNCTION get_jurations_by_juror_id(
  p_juror_id uuid
)
RETURNS SETOF jurations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM jurations
  WHERE juror_id = p_juror_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the jurations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;