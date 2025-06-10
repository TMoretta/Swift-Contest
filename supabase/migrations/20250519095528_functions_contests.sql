-- CREATE CONTEST
CREATE OR REPLACE FUNCTION create_contest (
  p_contest contests
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
BEGIN
  INSERT INTO contests (
    id,
    created_at,
    organizer_id,
    name,
    description,
    date_time,
    works_submission_from,
    works_submission_to,
    place_id,
    contest_status,
    images_urls,
    token,
    voting_form_id,
    is_deleted
  )
  VALUES (
    p_contest.id,
    p_contest.created_at,
    p_contest.organizer_id,
    p_contest.name,
    p_contest.description,
    p_contest.date_time,
    p_contest.works_submission_from,
    p_contest.works_submission_to,
    p_contest.place_id,
    p_contest.contest_status,
    p_contest.images_urls,
    p_contest.token,
    p_contest.voting_form_id,
    p_contest.is_deleted
  )
  RETURNING * INTO STRICT v_contest;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE CONTEST BY ID
CREATE OR REPLACE FUNCTION update_contest (
  p_contest contests
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
BEGIN
  -- Verify if the contest exists
  IF NOT EXISTS (SELECT 1 FROM contests WHERE id = p_contest.id) THEN
    RAISE EXCEPTION 'No contest found';
  END IF;

  UPDATE contests
  SET
    organizer_id = p_contest.organizer_id,
    name = p_contest.name,
    description = p_contest.description,
    date_time = p_contest.date_time,
    works_submission_from = p_contest.works_submission_from,
    works_submission_to = p_contest.works_submission_to,
    place_id = p_contest.place_id,
    contest_status = p_contest.contest_status,
    images_urls = p_contest.images_urls,
    token = p_contest.token,
    voting_form_id = p_contest.voting_form_id,
    is_deleted = p_contest.is_deleted
  WHERE contests.id = p_contest.id
  RETURNING * INTO STRICT v_contest;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- DELETE CONTEST BY ID
CREATE OR REPLACE FUNCTION delete_contest_by_id(
  p_id uuid
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
BEGIN
  -- Verify if the contest exists
  IF NOT EXISTS (SELECT 1 FROM contests WHERE id = p_id) THEN
    RAISE EXCEPTION 'No contest found';
  END IF;

  DELETE FROM contests
  WHERE id = p_id
  RETURNING * INTO STRICT v_contest;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTEST BY ID
CREATE OR REPLACE FUNCTION get_contest_by_id(
  p_id uuid
)
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM contests
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET ALL CONTESTS
CREATE OR REPLACE FUNCTION get_all_contests()
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM contests;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTESTS BY ORGANIZER ID
CREATE OR REPLACE FUNCTION get_contests_by_organizer_id(
    p_organizer_id uuid
)
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM contests
    WHERE organizer_id = p_organizer_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTEST BY TOKEN
CREATE OR REPLACE FUNCTION get_contest_by_token(
  p_token varchar
)
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM contests
    WHERE token = p_token;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;
