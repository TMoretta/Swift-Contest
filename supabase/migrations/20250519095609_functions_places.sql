-- CREATE PLACE
CREATE OR REPLACE FUNCTION public.create_place (
  p_id uuid,
  p_created_at timestamptz,
  p_address varchar(150),
  p_lat double precision,
  p_lon double precision
)
RETURNS SETOF public.places AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.places (
      id,
      created_at,
      address,
      lat,
      lon
    )
    VALUES (
      p_id,
      p_created_at,
      p_address,
      p_lat,
      p_lon
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE PLACE BY ID
CREATE OR REPLACE FUNCTION public.update_place (
  p_id uuid,
  p_created_at timestamptz,
  p_address varchar(150),
  p_lat double precision,
  p_lon double precision
)
RETURNS SETOF public.places AS $$
BEGIN
  RETURN QUERY
    UPDATE public.places
    SET
      created_at = p_created_at,
      address = p_address,
      lat = p_lat,
      lon = p_lon
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE PLACE BY ID
CREATE OR REPLACE FUNCTION public.delete_place_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.places
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PLACE BY ID
CREATE OR REPLACE FUNCTION public.get_place_by_id(
  p_id uuid
)
RETURNS SETOF public.places AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.places
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;