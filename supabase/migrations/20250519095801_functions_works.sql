-- CREATE WORK
CREATE OR REPLACE FUNCTION create_work (
  p_work works
)
RETURNS works AS $$
DECLARE
  v_work works;
BEGIN
  INSERT INTO works (
    id,
    created_at,
    participation_id,
    name,
    description,
    images_urls
  )
  VALUES (
    p_work.id,
    p_work.created_at,
    p_work.participation_id,
    p_work.name,
    p_work.description,
    p_work.images_urls
  )
  RETURNING * INTO STRICT v_work;

  RETURN v_work;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the work';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE WORK BY ID
CREATE OR REPLACE FUNCTION update_work (
  p_work works
)
RETURNS works AS $$
DECLARE
  v_work works;
BEGIN
  -- Verify if the work exists
  IF NOT EXISTS (SELECT 1 FROM works WHERE id = p_work.id) THEN
    RAISE EXCEPTION 'No work found';
  END IF;
  
  UPDATE works
  SET
    participation_id = p_work.participation_id,
    name = p_work.name,
    description = p_work.description,
    images_urls = p_work.images_urls
  WHERE id = p_work.id
  RETURNING * INTO STRICT v_work;
  
  RETURN v_work;
  
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the work';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE WORK BY ID
CREATE OR REPLACE FUNCTION delete_work_by_id (
  p_id uuid
)
RETURNS works AS $$
DECLARE
  v_work works;
BEGIN
  -- Verify if the work exists
  IF NOT EXISTS (SELECT 1 FROM works WHERE id = p_id) THEN
    RAISE EXCEPTION 'No work found';
  END IF;
  
  DELETE FROM works
  WHERE id = p_id
  RETURNING * INTO STRICT v_work;
  
  RETURN v_work;
  
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the work';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET WORK BY ID
CREATE OR REPLACE FUNCTION get_work_by_id(
  p_id uuid
)
RETURNS SETOF works AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM works
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the work';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET WORK BY PARTICIPATION ID
CREATE OR REPLACE FUNCTION get_work_by_participation_id(
  p_participation_id uuid
)
RETURNS SETOF works AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM works
    WHERE participation_id = p_participation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the work';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;