-- CREATE SIMPLE JUROR VOTE
CREATE OR REPLACE FUNCTION create_simple_juror_vote (
  p_simple_juror_vote simple_juror_votes
)
RETURNS simple_juror_votes AS $$
DECLARE
  v_simple_juror_vote simple_juror_votes;
BEGIN
  INSERT INTO simple_juror_votes (
    id,
    created_at,
    simple_juror_voting_id,
    voting_form_field_id,
    value
  )
  VALUES (
    p_id,
    p_created_at,
    p_simple_juror_voting_id,
    p_voting_form_field_id,
    p_value
  )
  RETURNING * INTO STRICT v_simple_juror_vote;

  RETURN v_simple_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the simple juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION update_simple_juror_vote (
  p_simple_juror_vote simple_juror_votes
)
RETURNS simple_juror_votes AS $$
DECLARE
  v_simple_juror_vote simple_juror_votes;
BEGIN
  -- Verify if the simple juror vote exists
  IF NOT EXISTS (SELECT 1 FROM simple_juror_votes WHERE id = p_simple_juror_vote.id) THEN
    RAISE EXCEPTION 'No simple juror vote found';
  END IF;

  UPDATE simple_juror_votes
  SET
    simple_juror_voting_id = p_simple_juror_vote.simple_juror_voting_id,
    voting_form_field_id = p_simple_juror_vote.voting_form_field_id,
    value = p_simple_juror_vote.value
  WHERE id = p_simple_juror_vote.id
  RETURNING * INTO STRICT v_simple_juror_vote;

  RETURN v_simple_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the simple juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION delete_simple_juror_vote_by_id(
  p_id uuid
)
RETURNS simple_juror_votes AS $$
DECLARE
  v_simple_juror_vote simple_juror_votes;
BEGIN
  -- Verify if the simple juror vote exists
  IF NOT EXISTS (SELECT 1 FROM simple_juror_votes WHERE id = p_id) THEN
    RAISE EXCEPTION 'No simple juror vote found';
  END IF;

  DELETE FROM simple_juror_votes
  WHERE id = p_id
  RETURNING * INTO STRICT v_simple_juror_vote;

  RETURN v_simple_juror_vote;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the simple juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION get_simple_juror_vote_by_id(
  p_id uuid
)
RETURNS SETOF simple_juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_juror_votes
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the simple juror vote';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTES BY SIMPLE JUROR VOTING ID
CREATE OR REPLACE FUNCTION get_simple_juror_votes_by_simple_juror_voting_id(
  p_simple_juror_voting_id uuid
)
RETURNS SETOF simple_juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM simple_juror_votes
    WHERE simple_juror_voting_id = p_simple_juror_voting_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the simple juror votes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;