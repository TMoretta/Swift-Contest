CREATE OR REPLACE FUNCTION get_current_user_and_profile (
  p_user_id uuid
)
RETURNS TABLE (
  m_user jsonb,
  profile jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      to_jsonb(u),
      to_jsonb(p)
    FROM auth.users u
    JOIN profiles p ON p.id = u.id
    WHERE u.id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current user and profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE FUNCTION get_current_user (
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

CREATE OR REPLACE FUNCTION get_current_profile (
  p_user_id uuid
)
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM profiles
    WHERE id = p_user_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting current profile';
END;
$$ LANGUAGE plpgsql SECURITY definer;

