-- USER CREATED TRIGGER
CREATE OR REPLACE TRIGGER user_created_trigger
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION public.auto_create_profile();

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
END;
$$ LANGUAGE plpgsql SECURITY definer;