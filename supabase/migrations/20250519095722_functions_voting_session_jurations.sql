-- CREATE VOTING SESSION JURATION
CREATE OR REPLACE FUNCTION create_voting_session_juration (
  p_voting_session_juration voting_session_jurations
)
RETURNS voting_session_jurations AS $$
DECLARE
  v_voting_session_juration voting_session_jurations;
BEGIN
  INSERT INTO voting_session_jurations (
    id,
    created_at,
    voting_session_id,
    juration_id,
    has_submitted
  )
  VALUES (
    p_voting_session_juration.id,
    p_voting_session_juration.created_at,
    p_voting_session_juration.voting_session_id,
    p_voting_session_juration.juration_id,
    p_voting_session_juration.has_submitted
  )
  RETURNING * INTO STRICT v_voting_session_juration;

  RETURN v_voting_session_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting session juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION JURATION BY ID
CREATE OR REPLACE FUNCTION update_voting_session_juration (
  p_voting_session_juration voting_session_jurations
)
RETURNS voting_session_jurations AS $$
DECLARE
  v_voting_session_juration voting_session_jurations;
BEGIN
  -- Verify if the voting session juration exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_jurations WHERE id = p_voting_session_juration.id) THEN
    RAISE EXCEPTION 'No voting session juration found';
  END IF;

  UPDATE voting_session_jurations
  SET
    voting_session_id = p_voting_session_juration.voting_session_id,
    juration_id = p_voting_session_juration.juration_id,
    has_submitted = p_voting_session_juration.has_submitted
  WHERE id = p_voting_session_juration.id
  RETURNING * INTO STRICT v_voting_session_juration;

  RETURN v_voting_session_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION JURATION BY ID
CREATE OR REPLACE FUNCTION delete_voting_session_juration_by_id(
  p_id uuid
)
RETURNS voting_session_jurations AS $$
DECLARE
  v_voting_session_juration voting_session_jurations;
BEGIN
  -- Verify if the voting session juration exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_jurations WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting session juration found';
  END IF;

  DELETE FROM voting_session_jurations
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_session_juration;

  RETURN v_voting_session_juration;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting session juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JURATION BY ID
CREATE OR REPLACE FUNCTION get_voting_session_juration_by_id(
  p_id uuid
)
RETURNS SETOF voting_session_jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_jurations
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JURATION BY VOTING SESSION ID AND JUROR ID
CREATE OR REPLACE FUNCTION get_vot_session_juration_by_voting_session_id_and_juration_id(
  p_voting_session_id uuid,
  p_juration_id uuid
)
RETURNS SETOF voting_session_jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_jurations
    WHERE voting_session_id = p_voting_session_id AND juration_id = p_juration_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session juration';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JURATIONS BY VOTING SESSION ID
CREATE OR REPLACE FUNCTION get_voting_session_jurations_by_voting_session_id(
  p_voting_session_id uuid
)
RETURNS SETOF voting_session_jurations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_jurations
    WHERE voting_session_id = p_voting_session_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session jurations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;