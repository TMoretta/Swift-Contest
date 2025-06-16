-- AUTO CREATE PROFILE
CREATE OR REPLACE FUNCTION auto_create_profile()
RETURNS trigger AS $$
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
    (new.raw_user_meta_data->>'full_name')::varchar,
    (new.raw_user_meta_data->>'pref_theme')::public.app_theme,
    (new.raw_user_meta_data->>'pref_contest_role')::public.contest_role,
    (new.raw_user_meta_data->>'is_deleted')::boolean
  );
  RETURN new;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Profile creation error: %', SQLERRM;
    RAISE EXCEPTION 'An error occurred while creating the profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE PROFILE BY ID
CREATE OR REPLACE FUNCTION update_profile (
  p_profile profiles
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  -- Verify if the profile exists
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_profile.id) THEN
    RAISE EXCEPTION 'No profile found';
  END IF;

  UPDATE profiles
  SET
    full_name = p_profile.full_name,
    pref_theme = p_profile.pref_theme,
    pref_contest_role = p_profile.pref_contest_role,
    is_deleted = p_profile.is_deleted
  WHERE id = p_profile.id
  RETURNING * INTO STRICT v_profile;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET PROFILE BY ID
CREATE OR REPLACE FUNCTION delete_profile_by_id (
  p_id uuid
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  -- Verify if a profile with the given id exists
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_id) THEN
    RAISE EXCEPTION 'No profile found';
  END IF;

  -- The profile exists so delete it
  DELETE FROM profiles
  WHERE id = p_id
  RETURNING * INTO STRICT v_profile;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET PROFILE BY ID
CREATE OR REPLACE FUNCTION get_profile_by_id (
  p_id uuid
)
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM profiles
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;
