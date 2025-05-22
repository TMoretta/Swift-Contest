-- AUTO CREATE PROFILE
CREATE OR REPLACE FUNCTION public.auto_create_profile()
RETURNS trigger
SET
  search_path = '' AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    created_at,
    full_name,
    pref_theme,
    pref_contest_role,
    is_deleted
  )
  VALUES (
    new.id,
    (new.raw_user_meta_data->>'created_at')::timestamptz,
    new.raw_user_meta_data->>'full_name',
    (new.raw_user_meta_data->>'pref_theme')::public.app_theme,
    (new.raw_user_meta_data->>'pref_contest_role')::public.contest_role,
    (new.raw_user_meta_data->>'is_deleted')::boolean
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE PROFILE BY ID
CREATE OR REPLACE FUNCTION public.update_profile_by_id (
  p_id uuid,
  p_created_at timestamptz,
  p_full_name text,
  p_pref_theme public.app_theme,
  p_pref_contest_role public.contest_role,
  p_is_deleted boolean
)
RETURNS SETOF public.profiles AS $$
BEGIN
  RETURN QUERY
    UPDATE public.profiles
    SET
      created_at = p_created_at,
      full_name = p_full_name,
      pref_theme = p_pref_theme,
      pref_contest_role = p_pref_contest_role,
      is_deleted = p_is_deleted
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET PROFILE BY ID
CREATE OR REPLACE FUNCTION public.get_profile_by_id (
  p_id uuid
)
RETURNS SETOF public.profiles AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.profiles
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;