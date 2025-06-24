-- CREATE VOTING SESSION PARTICIPATION
CREATE OR REPLACE FUNCTION create_voting_session_participation (
  p_voting_session_participation voting_session_participations
)
RETURNS voting_session_participations AS $$
DECLARE
  v_voting_session_participation voting_session_participations;
BEGIN
  INSERT INTO voting_session_participations (
    id,
    created_at,
    voting_session_id,
    participation_id,
    order_index,
    is_excluded
  )
  VALUES (
    p_voting_session_participation.id,
    p_voting_session_participation.created_at,
    p_voting_session_participation.voting_session_id,
    p_voting_session_participation.participation_id,
    p_voting_session_participation.order_index,
    p_voting_session_participation.is_excluded
  )
  RETURNING * INTO STRICT v_voting_session_participation;

  RETURN v_voting_session_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting session participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION update_voting_session_participation (
  p_voting_session_participation voting_session_participations
)
RETURNS voting_session_participations AS $$
DECLARE
  v_voting_session_participation voting_session_participations;
BEGIN
  -- Verify if the voting session participation exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_participations WHERE id = p_voting_session_participation.id) THEN
    RAISE EXCEPTION 'No voting session participation found';
  END IF;

  UPDATE voting_session_participations
  SET
    voting_session_id = p_voting_session_participation.voting_session_id,
    participation_id = p_voting_session_participation.participation_id,
    order_index = p_voting_session_participation.order_index,
    is_excluded = p_voting_session_participation.is_excluded
  WHERE id = p_voting_session_participation.id
  RETURNING * INTO STRICT v_voting_session_participation;

  RETURN v_voting_session_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION delete_voting_session_participation_by_id(
  p_id uuid
)
RETURNS voting_session_participations AS $$
DECLARE
  v_voting_session_participation voting_session_participations;
BEGIN
  -- Verify if the voting session participation exists
  IF NOT EXISTS (SELECT 1 FROM voting_session_participations WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting session participation found';
  END IF;

  DELETE FROM voting_session_participations
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_session_participation;

  RETURN v_voting_session_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting session participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION get_voting_session_participation_by_id(
  p_id uuid
)
RETURNS SETOF voting_session_participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_participations
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPATION BY VOTING SESSION ID AND PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_voting_session_participation_by_voting_session_id_and_participation_id(
  p_voting_session_id uuid,
  p_participation_id uuid
)
RETURNS SETOF voting_session_participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_participations
    WHERE voting_session_id = p_voting_session_id AND participation_id = p_participation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPATIONS BY VOTING SESSION ID
CREATE OR REPLACE FUNCTION get_voting_session_participations_by_voting_session_id(
  p_voting_session_id uuid
)
RETURNS SETOF voting_session_participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_session_participations
    WHERE voting_session_id = p_voting_session_id
    ORDER BY order_index;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting session participations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;