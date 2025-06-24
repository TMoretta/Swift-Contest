-- CREATE PLACE
CREATE OR REPLACE FUNCTION create_place (
  p_place places
)
RETURNS places AS $$
DECLARE
  v_place places;
BEGIN
  INSERT INTO places (
    id,
    created_at,
    address,
    lat,
    lon
  )
  VALUES (
    p_place.id,
    p_place.created_at,
    p_place.address,
    p_place.lat,
    p_place.lon
  )
  RETURNING * INTO STRICT v_place;

  RETURN v_place;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the place';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE PLACE BY ID
CREATE OR REPLACE FUNCTION update_place (
  p_place places
)
RETURNS places AS $$
DECLARE
  v_place places;
BEGIN
  -- Verify if the place exists
  IF NOT EXISTS (SELECT 1 FROM places WHERE id = p_place.id) THEN
    RAISE EXCEPTION 'No place found';
  END IF;

  UPDATE places
  SET
    address = p_place.address,
    lat = p_place.lat,
    lon = p_place.lon
  WHERE id = p_place.id
  RETURNING * INTO STRICT v_place;

  RETURN v_place;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the place';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE PLACE BY ID
CREATE OR REPLACE FUNCTION delete_place_by_id(
  p_id uuid
)
RETURNS places AS $$
DECLARE
  v_place places;
BEGIN
  -- Verify if the place exists
  IF NOT EXISTS (SELECT 1 FROM places WHERE id = p_id) THEN
    RAISE EXCEPTION 'No place found';
  END IF;

  DELETE FROM places
  WHERE id = p_id
  RETURNING * INTO STRICT v_place;

  RETURN v_place;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the place';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PLACE BY ID
CREATE OR REPLACE FUNCTION get_place_by_id(
  p_id uuid
)
RETURNS SETOF places AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM places
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the place';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;