-- CREATE JUROR VOTE
CREATE OR REPLACE FUNCTION create_juror_vote (
  p_juror_vote juror_votes
)
RETURNS juror_votes AS $$
DECLARE
  v_juror_vote juror_votes;
BEGIN
  INSERT INTO juror_votes (
    id,
    created_at,
    juror_voting_id,
    voting_form_field_id,
    value
  )
  VALUES (
    p_juror_vote.id,
    p_juror_vote.created_at,
    p_juror_vote.juror_voting_id,
    p_juror_vote.voting_form_field_id,
    p_juror_vote.value
  )
  RETURNING * INTO STRICT v_juror_vote;

  RETURN v_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION update_juror_vote (
  p_juror_vote juror_votes
)
RETURNS juror_votes AS $$
DECLARE
  v_juror_vote juror_votes;
BEGIN
  -- Verify if the juror vote exists
  IF NOT EXISTS (SELECT 1 FROM juror_votes WHERE id = p_juror_vote.id) THEN
    RAISE EXCEPTION 'No juror vote found';
  END IF;

  UPDATE juror_votes
  SET
    juror_voting_id = p_juror_vote.juror_voting_id,
    voting_form_field_id = p_juror_vote.voting_form_field_id,
    value = p_juror_vote.value
  WHERE id = p_juror_vote.id
  RETURNING * INTO STRICT v_juror_vote;

  RETURN v_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION delete_juror_vote_by_id(
  p_id uuid
)
RETURNS juror_votes AS $$
DECLARE
  v_juror_vote juror_votes;
BEGIN
  -- Verify if the juror vote exists
  IF NOT EXISTS (SELECT 1 FROM juror_votes WHERE id = p_id) THEN
    RAISE EXCEPTION 'No juror vote found';
  END IF;

  DELETE FROM juror_votes
  WHERE id = p_id
  RETURNING * INTO STRICT v_juror_vote;

  RETURN v_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION get_juror_vote_by_id(
  p_id uuid
)
RETURNS SETOF juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votes
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTES BY JUROR VOTING ID
CREATE OR REPLACE FUNCTION get_juror_votes_by_juror_voting_id(
  p_juror_voting_id uuid
)
RETURNS SETOF juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM juror_votes
    WHERE juror_voting_id = p_juror_voting_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the juror votes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;