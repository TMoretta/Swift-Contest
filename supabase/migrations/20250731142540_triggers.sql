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
-- Cleans up related data when a contest is deleted.
-- 1. Deletes associated images from the 'contests-images' storage bucket.
-- 2. Deletes the associated 'place' record.
CREATE OR REPLACE FUNCTION public.handle_contest_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- 1. Delete associated images from storage.
  -- The storage.remove function expects an array of paths.
  IF OLD.images_paths IS NOT NULL AND array_length(OLD.images_paths, 1) > 0 THEN
    PERFORM storage.remove(OLD.images_paths, 'contests-images');
  END IF;

  -- 2. Delete the associated place record.
  -- This is necessary because the foreign key is on the 'contests' table,
  -- so a cascade from 'places' is not possible.
  IF OLD.place_id IS NOT NULL THEN
    DELETE FROM public.places WHERE id = OLD.place_id;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_contest_delete
  AFTER DELETE ON public.contests
  FOR EACH ROW EXECUTE FUNCTION public.handle_contest_delete();
--endregion

--region ON WORK DELETE TRIGGER
-- Cleans up associated images from storage when a work is deleted.
CREATE OR REPLACE FUNCTION public.handle_work_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete associated images from the 'works-images' storage bucket.
  IF OLD.images_paths IS NOT NULL AND array_length(OLD.images_paths, 1) > 0 THEN
    PERFORM storage.remove(OLD.images_paths, 'works-images');
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_work_delete
  AFTER DELETE ON public.works
  FOR EACH ROW EXECUTE FUNCTION public.handle_work_delete();
--endregion

--region ON CONTEST RANKING DELETE TRIGGER
-- Cleans up the associated file from storage when a contest ranking is deleted.
CREATE OR REPLACE FUNCTION public.handle_contest_ranking_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete the associated file from the 'contests-rankings' storage bucket.
  IF OLD.file_path IS NOT NULL THEN
    -- storage.remove expects an array of paths, so we wrap the single path in an array.
    PERFORM storage.remove(ARRAY[OLD.file_path], 'contests-rankings');
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_contest_ranking_delete
  AFTER DELETE ON public.contest_rankings
  FOR EACH ROW EXECUTE FUNCTION public.handle_contest_ranking_delete();
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
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_jury_delete
  AFTER DELETE ON public.juries
  FOR EACH ROW EXECUTE FUNCTION public.handle_jury_delete();
--endregion
