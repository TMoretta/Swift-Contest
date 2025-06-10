-- CREATE SIMPLE JUROR VOTING
CREATE OR REPLACE FUNCTION create_simple_juror_voting (
  p_simple_juror_voting simple_juror_votings
)
RETURNS simple_juror_votings AS $$
DECLARE
  v_simple_juror_voting simple_juror_votings;
BEGIN
  INSERT INTO simple_juror_votings (
    id,
    created_at,
    voting_session_id,
    voting_session_simple_juror_id,
    voting_session_participation_id
  )
  VALUES (
    p_simple_juror_voting.id,
    p_simple_juror_voting.created_at,
    p_simple_juror_voting.voting_session_id,
    p_simple_juror_voting.voting_session_simple_juror_id,
    p_simple_juror_voting.voting_session_participation_id
  )
  RETURNING * INTO STRICT v_simple_juror_voting;

  RETURN v_simple_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the simple juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION update_simple_juror_voting (
  p_simple_juror_voting simple_juror_votings
)
RETURNS simple_juror_votings AS $$
DECLARE
  v_simple_juror_voting simple_juror_votings;
BEGIN
  -- Verify if the simple juror voting exists
  IF NOT EXISTS (SELECT 1 FROM simple_juror_votings WHERE id = p_simple_juror_voting.id) THEN
    RAISE EXCEPTION 'No simple juror voting found';
  END IF;

  UPDATE simple_juror_votings
  SET
    voting_session_id = p_simple_juror_voting.voting_session_id,
    voting_session_simple_juror_id = p_simple_juror_voting.voting_session_simple_juror_id,
    voting_session_participation_id = p_simple_juror_voting.voting_session_participation_id
  WHERE id = p_simple_juror_voting.id
  RETURNING * INTO STRICT v_simple_juror_voting;

  RETURN v_simple_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the simple juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION delete_simple_juror_voting_by_id(
  p_id uuid
)
RETURNS simple_juror_votings AS $$
DECLARE
  v_simple_juror_voting simple_juror_votings;
BEGIN
  -- Verify if the simple juror voting exists
  IF NOT EXISTS (SELECT 1 FROM simple_juror_votings WHERE id = p_id) THEN
    RAISE EXCEPTION 'No simple juror voting found';
  END IF;

  DELETE FROM simple_juror_votings
  WHERE id = p_id
  RETURNING * INTO STRICT v_simple_juror_voting;

  RETURN v_simple_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the simple juror voting';
END
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION get_simple_juror_voting_by_id(
  p_id uuid
)
RETURNS SETOF simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_juror_votings
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the simple juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTINGS BY VOTING SESSION SIMPLE JUROR ID
CREATE OR REPLACE FUNCTION get_simple_juror_votings_by_voting_session_simple_juror_id(
  p_voting_session_simple_juror_id uuid
)
RETURNS SETOF simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_juror_votings
    WHERE voting_session_simple_juror_id = p_voting_session_simple_juror_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the simple juror votings';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING BY VOTING SESSION SIMPLE JUROR ID AND VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_simple_jur_voting_by_vot_ses_sim_jur_id_and_vot_ses_par_id(
  p_voting_session_simple_juror_id uuid,
  p_voting_session_participation_id uuid
)
RETURNS SETOF simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_juror_votings
    WHERE voting_session_simple_juror_id = p_voting_session_simple_juror_id
      AND voting_session_participation_id = p_voting_session_participation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the simple juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;