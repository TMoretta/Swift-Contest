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
--endregion

--region ON CONTEST DELETE TRIGGER
CREATE OR REPLACE FUNCTION public.handle_contest_delete()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM public.places WHERE id = OLD.place_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_contest_delete
  AFTER DELETE ON public.contests
  FOR EACH ROW EXECUTE FUNCTION public.handle_contest_delete();
--endregion

--region ON VOTING SESSION DELETE TRIGGER
CREATE OR REPLACE FUNCTION public.handle_voting_session_delete()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM public.places WHERE id = OLD.geo_res_place_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_voting_session_delete
  AFTER DELETE ON public.voting_sessions
  FOR EACH ROW EXECUTE FUNCTION public.handle_voting_session_delete();
--endregion

--region ON JURY DELETE TRIGGER
-- Cleans up the associated voting form when a jury is deleted.
CREATE OR REPLACE FUNCTION public.handle_jury_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete the associated voting_form record.
  -- This is necessary because the foreign key is on the 'juries' table,
  -- so a cascade from 'voting_forms' is not possible.
  DELETE FROM public.voting_forms WHERE id = OLD.voting_form_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_jury_delete
  AFTER DELETE ON public.juries
  FOR EACH ROW EXECUTE FUNCTION public.handle_jury_delete();
--endregion

--region ON VOTING SESSION JURY DELETE TRIGGER
-- Cleans up the associated voting form when a voting_session_jury is deleted.
CREATE OR REPLACE FUNCTION public.handle_voting_session_jury_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete the associated voting_form record.
  -- This is necessary because the foreign key is on the 'juries' table,
  -- so a cascade from 'voting_forms' is not possible.
  DELETE FROM public.voting_forms WHERE id = OLD.voting_form_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE TRIGGER on_voting_session_jury_delete
  AFTER DELETE ON public.voting_session_juries
  FOR EACH ROW EXECUTE FUNCTION public.handle_voting_session_jury_delete();
--endregion
