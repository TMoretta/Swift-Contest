-- USER CREATED TRIGGER
CREATE OR REPLACE TRIGGER user_created_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION auto_create_profile();

-- todo: Remove
ALTER TABLE auth.users
DISABLE TRIGGER user_created_trigger;

-- GET USER BY EMAIL
CREATE OR REPLACE FUNCTION get_user_by_email (
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