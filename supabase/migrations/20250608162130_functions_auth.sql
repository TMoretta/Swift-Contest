-- AUTO CREATE PROFILE
CREATE OR REPLACE FUNCTION auto_create_profile()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    user_id,
    full_name
  )
  VALUES (
    new.id,
    (new.raw_user_meta_data->>'full_name')::varchar
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

-- USER CREATED TRIGGER
CREATE OR REPLACE TRIGGER user_created_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION auto_create_profile();

-- todo: Remove
ALTER TABLE auth.users
DISABLE TRIGGER user_created_trigger;

-- GET USER BY EMAIL
CREATE OR REPLACE FUNCTION public.get_user_by_email (
  p_email varchar
)
RETURNS SETOF auth.users AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM auth.users
    WHERE email = p_email;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the user';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET USER INFO
CREATE OR REPLACE FUNCTION get_user_auth_bundle (
  p_user_id uuid
)
RETURNS TABLE (
  m_user jsonb,
  profile jsonb,
  messages jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      to_jsonb(u),
      to_jsonb(p),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at DESC)
        FROM messages m
        WHERE m.profile_id = p.id
      ), '[]'::jsonb)
    FROM auth.users u
    JOIN profiles p ON p.user_id = u.id
    WHERE u.id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current user info';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET USER
CREATE OR REPLACE FUNCTION get_user (
  p_user_id uuid
)
RETURNS SETOF auth.users AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM auth.users
    WHERE id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current user';
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE FUNCTION get_profile (
  p_user_id uuid
)
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM profiles
    WHERE user_id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET PROFILE MESSAGES
CREATE OR REPLACE FUNCTION get_profile_messages (
  p_user_id uuid
)
RETURNS SETOF messages AS $$
BEGIN
  RETURN QUERY
    SELECT mes.*
    FROM messages mes
    JOIN profiles pro ON pro.id = mes.profile_id
    JOIN auth.users use ON use.id = pro.user_id
    WHERE use.id = p_user_id
    ORDER BY created_at DESC;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current profile messages';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE PROFILE FULL NAME
CREATE OR REPLACE FUNCTION update_profile_full_name (
  p_user_id uuid,
  p_full_name varchar
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  UPDATE profiles
  SET
    full_name = p_full_name
  WHERE user_id = p_user_id
  RETURNING * INTO STRICT v_profile;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating full name';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE PROFILE PREF THEME
CREATE OR REPLACE FUNCTION update_profile_pref_theme (
  p_user_id uuid,
  p_pref_theme app_theme
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  UPDATE profiles
  SET
    pref_theme = p_pref_theme
  WHERE user_id = p_user_id
  RETURNING * INTO STRICT v_profile;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating preferred theme';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE PROFILE PREF ROLE
CREATE OR REPLACE FUNCTION update_profile_pref_role (
  p_user_id uuid,
  p_pref_role contest_role
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  UPDATE profiles
  SET
    pref_role = p_pref_role
  WHERE user_id = p_user_id
  RETURNING * INTO STRICT v_profile;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating preferred role';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- MARK MESSAGE AS READ
CREATE OR REPLACE FUNCTION mark_message_as_read (
  p_message_id uuid
)
RETURNS void AS $$
BEGIN
  UPDATE messages
  SET is_read = 'true'
  WHERE id = p_message_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while marking message as read';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- DELETE USER
CREATE OR REPLACE FUNCTION delete_user (
  p_user_id uuid
)
RETURNS void AS $$
BEGIN

  UPDATE profiles
  SET
    user_id = '00000000-0000-0000-0000-000000000000',
    deleted_at = now()
  WHERE user_id = p_user_id;

  DELETE FROM auth.users
  WHERE id = p_user_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;