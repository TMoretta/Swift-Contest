--region ON USER CREATED TRIGGER
CREATE OR REPLACE FUNCTION public.handle_user_create ()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
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
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE TRIGGER on_user_create
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION handle_user_create ();