-- CREATE SIMPLE JUROR
CREATE OR REPLACE FUNCTION create_simple_juror (
  p_simple_juror simple_jurors
)
RETURNS simple_jurors AS $$
DECLARE
  v_simple_juror simple_jurors;
BEGIN
  INSERT INTO simple_jurors (
    id,
    created_at,
    full_name
  )
  VALUES (
    p_simple_juror.id,
    p_simple_juror.created_at,
    p_simple_juror.full_name
  )
  RETURNING * INTO STRICT v_simple_juror;

  RETURN v_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION update_simple_juror (
  p_simple_juror simple_jurors
)
RETURNS simple_jurors AS $$
DECLARE
  v_simple_juror simple_jurors;
BEGIN
  -- Verify if the simple juror exists
  IF NOT EXISTS (SELECT 1 FROM simple_jurors WHERE id = p_simple_juror.id) THEN
    RAISE EXCEPTION 'No simple juror found';
  END IF;

  UPDATE simple_jurors
  SET
    full_name = p_simple_juror.full_name
  WHERE id = p_simple_juror.id
  RETURNING * INTO STRICT v_simple_juror;

  RETURN v_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION delete_simple_juror_by_id(
  p_id uuid
)
RETURNS simple_jurors AS $$
DECLARE
  v_simple_juror simple_jurors;
BEGIN
  -- Verify if the simple juror exists
  IF NOT EXISTS (SELECT 1 FROM simple_jurors WHERE id = p_id) THEN
    RAISE EXCEPTION 'No simple juror found';
  END IF;

  DELETE FROM simple_jurors
  WHERE id = p_id
  RETURNING * INTO STRICT v_simple_juror;

  RETURN v_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION get_simple_juror_by_id(
  p_id uuid
)
RETURNS SETOF simple_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_jurors
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;