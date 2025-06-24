-- CREATE VOTING SESSION
CREATE OR REPLACE FUNCTION create_voting_session (
  p_voting_session voting_sessions
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_session voting_sessions;
BEGIN
  INSERT INTO voting_sessions (
    id,
    created_at,
    name,
    contest_id,
    are_simple_jurors_allowed,
    voting_form_id,
    work_timer,
    intermission_timer,
    review_timer,
    session_status,
    token,
    is_geo_restricted,
    geo_restriction_place_id,
    geo_restriction_radius
  )
  VALUES (
    p_voting_session.id,
    p_voting_session.created_at,
    p_voting_session.name,
    p_voting_session.contest_id,
    p_voting_session.are_simple_jurors_allowed,
    p_voting_session.voting_form_id,
    p_voting_session.work_timer,
    p_voting_session.intermission_timer,
    p_voting_session.review_timer,
    p_voting_session.session_status,
    p_voting_session.token,
    p_voting_session.is_geo_restricted,
    p_voting_session.geo_restriction_place_id,
    p_voting_session.geo_restriction_radius
  )
  RETURNING * INTO STRICT v_voting_session;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting session';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION update_voting_session (
  p_voting_session voting_sessions
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_session voting_sessions;
BEGIN
  -- Verify if the voting session exists
  IF NOT EXISTS (SELECT 1 FROM voting_sessions WHERE id = p_voting_session.id) THEN
    RAISE EXCEPTION 'No voting session found';
  END IF;

  UPDATE voting_sessions
  SET
    name = p_voting_session.name,
    contest_id = p_voting_session.contest_id,
    are_simple_jurors_allowed = p_voting_session.are_simple_jurors_allowed,
    voting_form_id = p_voting_session.voting_form_id,
    work_timer = p_voting_session.work_timer,
    intermission_timer = p_voting_session.intermission_timer,
    review_timer = p_voting_session.review_timer,
    session_status = p_voting_session.session_status,
    token = p_voting_session.token,
    is_geo_restricted = p_voting_session.is_geo_restricted,
    geo_restriction_place_id = p_voting_session.geo_restriction_place_id,
    geo_restriction_radius = p_voting_session.geo_restriction_radius
  WHERE id = p_voting_session.id
  RETURNING * INTO STRICT v_voting_session;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION delete_voting_session_by_id(
  p_id uuid
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_session voting_sessions;
BEGIN
  -- Verify if the voting session exists
  IF NOT EXISTS (SELECT 1 FROM voting_sessions WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting session found';
  END IF;

  DELETE FROM voting_sessions
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_session;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting session';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION get_voting_session_by_id(
  p_id uuid
)
RETURNS SETOF voting_sessions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_sessions
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION get_voting_sessions_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF voting_sessions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_sessions
    WHERE contest_id = p_contest_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting sessions';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION BY TOKEN
CREATE OR REPLACE FUNCTION get_voting_session_by_token(
  p_token varchar
)
RETURNS SETOF voting_sessions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_sessions
    WHERE token = p_token;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;