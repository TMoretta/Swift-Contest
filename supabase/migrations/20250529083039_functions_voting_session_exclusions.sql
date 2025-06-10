-- Create Voting Session Exclusion
CREATE OR REPLACE FUNCTION create_voting_session_exclusion (
  p_voting_session_exclusion voting_session_exclusions
)
RETURNS voting_session_exclusions AS $$
DECLARE
  v_voting_session_exclusion voting_session_exclusions;
BEGIN
  INSERT INTO voting_session_exclusions (
    id,
    created_at,
    voting_session_juration_id,
    voting_session_participation_id
  )
  VALUES (
    p_voting_session_exclusion.id,
    p_voting_session_exclusion.created_at,
    p_voting_session_exclusion.voting_session_juration_id,
    p_voting_session_exclusion.voting_session_participation_id
  )
  RETURNING * INTO STRICT v_voting_session_exclusion;

  RETURN v_voting_session_exclusion;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting session exclusion';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Update Voting Session Exclusion
CREATE OR REPLACE FUNCTION update_voting_session_exclusion (
  p_voting_session_exclusion voting_session_exclusions
)
RETURNS voting_session_exclusions AS $$
DECLARE
  v_voting_session_exclusion voting_session_exclusions;
BEGIN
  -- Verify if the voting session exclusion exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_exclusions WHERE id = p_voting_session_exclusion.id) THEN
    RAISE EXCEPTION 'No voting session exclusion found';
  END IF;

  UPDATE voting_session_exclusions
  SET
    voting_session_juration_id = p_voting_session_exclusion.voting_session_juration_id,
    excluded_participant_id = p_voting_session_exclusion.excluded_participant_id
  WHERE id = p_voting_session_exclusion.id
  RETURNING * INTO STRICT v_voting_session_exclusion;

  RETURN v_voting_session_exclusion;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session exclusion';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Delete Voting Session Exclusion By ID
CREATE OR REPLACE FUNCTION delete_voting_session_exclusion_by_id (
  p_id UUID
)
RETURNS voting_session_exclusions AS $$
DECLARE
  v_voting_session_exclusion voting_session_exclusions;
BEGIN
  -- Verify if the voting session exclusion exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_exclusions WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting session exclusion found';
  END IF;

  DELETE FROM voting_session_exclusions
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_session_exclusion;

  RETURN v_voting_session_exclusion;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting session exclusion';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Get Voting Session Exclusion By ID
CREATE OR REPLACE FUNCTION get_voting_session_exclusion_by_id (
  p_id UUID
)
RETURNS SETOF voting_session_exclusions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_exclusions
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session exclusion';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Get Voting Session Exclusion By Voting Session Juration ID
CREATE OR REPLACE FUNCTION get_voting_session_exclusions_by_voting_session_juration_id (
  p_voting_session_juration_id UUID
)
RETURNS SETOF voting_session_exclusions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_exclusions
    WHERE voting_session_juration_id = p_voting_session_juration_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session exclusions';
END;
$$ LANGUAGE plpgsql SECURITY definer;