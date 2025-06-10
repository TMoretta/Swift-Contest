-- CREATE PARTICIPATION
CREATE OR REPLACE FUNCTION create_participation (
  p_participation participations
)
RETURNS participations AS $$
DECLARE
  v_participation participations;
BEGIN
  INSERT INTO participations (
    id,
    created_at,
    contest_id,
    participant_id,
    participant_status,
    has_submitted
  )
  VALUES (
    p_participation.id,
    p_participation.created_at,
    p_participation.contest_id,
    p_participation.participant_id,
    p_participation.participant_status,
    p_participation.has_submitted
  )
  RETURNING * INTO STRICT v_participation;

  RETURN v_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION update_participation (
  p_participation participations
)
RETURNS participations AS $$
DECLARE
  v_participation participations;
BEGIN
  -- Verify if the participation exists
  IF NOT EXISTS (SELECT 1 FROM participations WHERE id = p_participation.id) THEN
    RAISE EXCEPTION 'No participation found';
  END IF;

  UPDATE participations
  SET
    contest_id = p_participation.contest_id,
    participant_id = p_participation.participant_id,
    participant_status = p_participation.participant_status,
    has_submitted = p_participation.has_submitted
  WHERE id = p_participation.id
  RETURNING * INTO STRICT v_participation;

  RETURN v_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION delete_participation_by_id(
  p_id uuid
)
RETURNS participations AS $$
DECLARE
  v_participation participations;
BEGIN
  -- Verify if the participation exists
  IF NOT EXISTS (SELECT 1 FROM participations WHERE id = p_id) THEN
    RAISE EXCEPTION 'No participation found';
  END IF;

  DELETE FROM participations
  WHERE id = p_id
  RETURNING * INTO STRICT v_participation;

  RETURN v_participation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION get_participation_by_id(
  p_id uuid
)
RETURNS SETOF participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM participations
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATION BY CONTEST ID AND PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_participation_by_contest_id_and_participant_id(
  p_contest_id uuid,
  p_participant_id uuid
)
RETURNS SETOF participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM participations
    WHERE contest_id = p_contest_id AND participant_id = p_participant_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the participation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION get_participations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF participations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM participations
  WHERE contest_id = p_contest_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the participations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATIONS BY PARTICIPANT ID
CREATE OR REPLACE FUNCTION get_participations_by_participant_id(
  p_participant_id uuid
)
RETURNS SETOF participations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM participations
  WHERE participant_id = p_participant_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the participations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;