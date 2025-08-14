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

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE TRIGGER on_user_create
AFTER INSERT ON auth.users FOR EACH ROW
EXECUTE FUNCTION handle_user_create ();