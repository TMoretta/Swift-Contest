-- CREATE WORK
CREATE OR REPLACE FUNCTION public.create_work (
  p_id uuid,
  p_created_at timestamptz,
  p_participation_id uuid,
  p_name character varying(20),
  p_description character varying(200),
  p_images_urls text[]
)
RETURNS SETOF public.works AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.works (
      id,
      created_at,
      participation_id,
      name,
      description,
      images_urls
    )
    VALUES (
      p_id,
      p_created_at,
      p_participation_id,
      p_name,
      p_description,
      p_images_urls
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE WORK BY ID
CREATE OR REPLACE FUNCTION public.update_work (
  p_id uuid,
  p_created_at timestamptz,
  p_participation_id uuid,
  p_name character varying(20),
  p_description character varying(200),
  p_images_urls text[]
)
RETURNS SETOF public.works AS $$
BEGIN
  RETURN QUERY
    UPDATE public.works
    SET
      created_at = p_created_at,
      participation_id = p_participation_id,
      name = p_name,
      description = p_description,
      images_urls = p_images_urls
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE WORK BY ID
CREATE OR REPLACE FUNCTION public.delete_work_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.works
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET WORK BY ID
CREATE OR REPLACE FUNCTION public.get_work_by_id(
  p_id uuid
)
RETURNS SETOF public.works AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.works
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET WORK BY PARTICIPATION ID
CREATE OR REPLACE FUNCTION public.get_work_by_participation_id(
  p_participation_id uuid
)
RETURNS SETOF public.works AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.works
    WHERE participation_id = p_participation_id
    LIMIT 1; -- Assuming one work per participation or returning the first one.
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;