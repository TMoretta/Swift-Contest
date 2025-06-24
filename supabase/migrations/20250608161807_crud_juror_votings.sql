-- CREATE JUROR VOTING
CREATE OR REPLACE FUNCTION create_juror_voting (
  p_juror_voting juror_votings
)
RETURNS juror_votings AS $$
DECLARE
  v_juror_voting juror_votings;
BEGIN
  INSERT INTO juror_votings (
    id,
    created_at,
    voting_session_juration_id,
    voting_session_participation_id
  )
  VALUES (
    p_juror_voting.id,
    p_juror_voting.created_at,
    p_juror_voting.voting_session_juration_id,
    p_juror_voting.voting_session_participation_id
  )
  RETURNING * INTO STRICT v_juror_voting;

  RETURN v_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION update_juror_voting (
  p_juror_voting juror_votings
)
RETURNS juror_votings AS $$
DECLARE
  v_juror_voting juror_votings;
BEGIN
  -- Verify if the juror voting exists
  IF NOT EXISTS (SELECT 1 FROM juror_votings WHERE id = p_juror_voting.id) THEN
    RAISE EXCEPTION 'No juror voting found';
  END IF;

  UPDATE juror_votings
  SET
    voting_session_juration_id = p_juror_voting.voting_session_juration_id,
    voting_session_participation_id = p_juror_voting.voting_session_participation_id
  WHERE id = p_juror_voting.id
  RETURNING * INTO STRICT v_juror_voting;

  RETURN v_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION delete_juror_voting_by_id(
  p_id uuid
)
RETURNS juror_votings AS $$
DECLARE
  v_juror_voting juror_votings;
BEGIN
  -- Verify if the juror voting exists
  IF NOT EXISTS (SELECT 1 FROM juror_votings WHERE id = p_id) THEN
    RAISE EXCEPTION 'No juror voting found';
  END IF;

  DELETE FROM juror_votings
  WHERE id = p_id
  RETURNING * INTO STRICT v_juror_voting;

  RETURN v_juror_voting;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION get_juror_voting_by_id(
  p_id uuid
)
RETURNS SETOF juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votings
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTING BY VOTING SESSION JUROR ID AND VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_juror_voting_by_vot_ses_jur_id_and_vot_ses_par_id(
  p_voting_session_juration_id uuid,
  p_voting_session_participation_id uuid
)
RETURNS SETOF juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votings
    WHERE voting_session_juration_id = p_voting_session_juration_id
      AND voting_session_participation_id = p_voting_session_participation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror voting';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTINGS BY VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_juror_votings_by_voting_session_participation_id(
  p_voting_session_participation_id uuid
)
RETURNS SETOF juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votings
    WHERE voting_session_participation_id = p_voting_session_participation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror votings';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTINGS BY VOTING SESSION JUROR ID
CREATE OR REPLACE FUNCTION get_juror_votings_by_voting_session_juration_id(
  p_voting_session_juration_id uuid
)
RETURNS SETOF juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votings
    WHERE voting_session_juration_id = p_voting_session_juration_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror votings';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;