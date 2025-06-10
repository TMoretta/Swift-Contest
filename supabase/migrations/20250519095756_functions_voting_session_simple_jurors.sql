-- CREATE VOTING SESSION SIMPLE JUROR
CREATE OR REPLACE FUNCTION create_voting_session_simple_juror (
  p_voting_session_simple_juror voting_session_simple_jurors
)
RETURNS voting_session_simple_jurors AS $$
DECLARE
  v_voting_session_simple_juror voting_session_simple_jurors;
BEGIN
  INSERT INTO voting_session_simple_jurors (
    id,
    created_at,
    voting_session_id,
    simple_juror_id,
    has_submitted
  )
  VALUES (
    p_voting_session_simple_juror.id,
    p_voting_session_simple_juror.created_at,
    p_voting_session_simple_juror.voting_session_id,
    p_voting_session_simple_juror.simple_juror_id,
    p_voting_session_simple_juror.has_submitted
  )
  RETURNING * INTO STRICT v_voting_session_simple_juror;

  RETURN v_voting_session_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting session simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION update_voting_session_simple_juror (
  p_voting_session_simple_juror voting_session_simple_jurors
)
RETURNS voting_session_simple_jurors AS $$
DECLARE
  v_voting_session_simple_juror voting_session_simple_jurors;
BEGIN
  -- Verify if the voting session simple juror exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_simple_jurors WHERE id = p_voting_session_simple_juror.id) THEN
    RAISE EXCEPTION 'No voting session simple juror found';
  END IF;

  UPDATE voting_session_simple_jurors
  SET
    voting_session_id = p_voting_session_simple_juror.voting_session_id,
    simple_juror_id = p_voting_session_simple_juror.simple_juror_id,
    has_submitted = p_voting_session_simple_juror.has_submitted
  WHERE id = p_voting_session_simple_juror.id
  RETURNING * INTO STRICT v_voting_session_simple_juror;

  RETURN v_voting_session_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION delete_voting_session_simple_juror_by_id(
  p_id uuid
)
RETURNS voting_session_simple_jurors AS $$
DECLARE
  v_voting_session_simple_juror voting_session_simple_jurors;
BEGIN
  -- Verify if the voting session simple juror exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_simple_jurors WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting session simple juror found';
  END IF;

  DELETE FROM voting_session_simple_jurors
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_session_simple_juror;

  RETURN v_voting_session_simple_juror;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting session simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION SIMPLE JUROR BY ID
CREATE OR REPLACE FUNCTION get_voting_session_simple_juror_by_id(
  p_id uuid
)
RETURNS SETOF voting_session_simple_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_simple_jurors
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session simple juror';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION SIMPLE JURORS BY VOTING SESSION ID
CREATE OR REPLACE FUNCTION get_voting_session_simple_jurors_by_voting_session_id(
  p_voting_session_id uuid
)
RETURNS SETOF voting_session_simple_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_simple_jurors
    WHERE voting_session_id = p_voting_session_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session simple jurors';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;