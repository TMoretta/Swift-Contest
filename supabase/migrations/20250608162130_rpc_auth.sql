--region AUTO CREATE PROFILE
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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile creation error';
  END IF;

  RETURN new;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region USER CREATED TRIGGER
CREATE OR REPLACE TRIGGER user_created_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION auto_create_profile();

-- todo: Remove
ALTER TABLE auth.users
DISABLE TRIGGER user_created_trigger;

--region VERIFY USER EXISTENCE BY ID
CREATE OR REPLACE FUNCTION verify_user_existence_by_id (
  p_user_id uuid
)
RETURNS boolean AS $$
BEGIN

  IF EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region VERIFY USER EXISTENCE BY EMAIL
CREATE OR REPLACE FUNCTION verify_user_existence_by_email (
  p_email varchar
)
RETURNS boolean AS $$
BEGIN

  IF EXISTS (
    SELECT 1 FROM auth.users
    WHERE email = p_email AND deleted_at is null
  ) THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region GET USER AUTH BUNDLE
CREATE OR REPLACE FUNCTION get_user_auth_bundle (
  p_user_id uuid
)
RETURNS TABLE (
  m_user jsonb,
  profile jsonb,
  messages jsonb
) AS $$
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  RETURN QUERY
    SELECT
      to_jsonb(u),
      to_jsonb(p),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at DESC)
        FROM messages m
        WHERE m.profile_id = p.id AND m.deleted_at is null
        ),
        '[]'::jsonb
      )
    FROM auth.users u
    JOIN profiles p ON p.user_id = u.id
    WHERE u.id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region GET USER
CREATE OR REPLACE FUNCTION get_user (
  p_user_id uuid
)
RETURNS SETOF auth.users AS $$
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  RETURN QUERY
    SELECT * FROM auth.users
    WHERE id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region GET PROFILE
CREATE OR REPLACE FUNCTION get_profile (
  p_user_id uuid
)
RETURNS SETOF profiles AS $$
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  RETURN QUERY
    SELECT * FROM profiles
    WHERE user_id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region GET PROFILE MESSAGES
CREATE OR REPLACE FUNCTION get_profile_messages (
  p_user_id uuid
)
RETURNS SETOF messages AS $$
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  RETURN QUERY
    SELECT mes.*
    FROM messages mes
    JOIN profiles pro ON pro.id = mes.profile_id
    JOIN auth.users use ON use.id = pro.user_id
    WHERE use.id = p_user_id AND mes.deleted_at is null
    ORDER BY created_at DESC;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region UPDATE PROFILE FULL NAME
CREATE OR REPLACE FUNCTION update_profile_full_name (
  p_user_id uuid,
  p_full_name varchar
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  UPDATE profiles
  SET full_name = p_full_name
  WHERE user_id = p_user_id
  RETURNING * INTO v_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating profile';
  END IF;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region UPDATE PROFILE PREF ROLE
CREATE OR REPLACE FUNCTION update_profile_pref_role (
  p_user_id uuid,
  p_pref_role contest_role
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF (auth.uid() <> p_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = p_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  UPDATE profiles
  SET pref_role = p_pref_role
  WHERE user_id = p_user_id
  RETURNING * INTO v_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating profile';
  END IF;

  RETURN v_profile;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region MARK MESSAGE AS READ
CREATE OR REPLACE FUNCTION mark_message_as_read (
  p_message_id uuid
)
RETURNS messages AS $$
DECLARE
  v_user_id uuid;
  v_message messages;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT u.id INTO v_user_id
  FROM auth.users u
  JOIN profiles p ON p.user_id = u.id
  JOIN messages m ON m.profile_id = p.id
  WHERE m.id = p_message_id
  LIMIT 1;

  IF (auth.uid() <> v_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM messages
    WHERE id = p_message_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Message not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM messages
    WHERE id = p_message_id AND is_read = false
  ) THEN
    RAISE EXCEPTION 'Message has been already marked as read';
  END IF;

  UPDATE messages
  SET is_read = 'true'
  WHERE id = p_message_id
  RETURNING * INTO v_message;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating message';
  END IF;

  RETURN v_message;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region DELETE MESSAGE
CREATE OR REPLACE FUNCTION delete_message (
  p_message_id uuid
)
RETURNS messages AS $$
DECLARE
  v_user_id uuid;
  v_message messages;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT u.id INTO v_user_id
  FROM auth.users u
  JOIN profiles p ON p.user_id = u.id
  JOIN messages m ON m.profile_id = p.id
  WHERE m.id = p_message_id
  LIMIT 1;

  IF (auth.uid() <> v_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM messages
    WHERE id = p_message_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Message not found';
  END IF;

  UPDATE messages
  SET deleted_at = now()
  WHERE id = p_message_id
  RETURNING * INTO v_message;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating message';
  END IF;

  RETURN v_message;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region DELETE ALL MESSAGES
CREATE OR REPLACE FUNCTION delete_all_profile_messages (
  p_profile_id uuid
)
RETURNS void AS $$
DECLARE
  v_user_id uuid;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT u.id INTO v_user_id
  FROM auth.users u
  JOIN profiles p ON p.user_id = u.id
  WHERE p.id = p_profile_id
  LIMIT 1;

  IF (auth.uid() <> v_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM profiles
    WHERE user_id = v_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'Profile not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM messages
    WHERE profile_id = p_profile_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'No message to delete';
  END IF;

  UPDATE messages
  SET deleted_at = now()
  WHERE profile_id = p_profile_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting messages';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE LOG 'Error: %', SQLERRM;
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

