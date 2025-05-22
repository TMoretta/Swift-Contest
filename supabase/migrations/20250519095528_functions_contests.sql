-- CREATE CONTEST
CREATE OR REPLACE FUNCTION public.create_contest (
  p_id uuid,
  p_created_at timestamptz,
  p_organizer_id uuid,
  p_name varchar,
  p_description varchar,
  p_date_time timestamptz,
  p_works_submission_from timestamptz,
  p_works_submission_to timestamptz,
  p_place_id uuid,
  p_contest_status public.contest_status,
  p_images_urls text[],
  p_token varchar,
  p_voting_form_id uuid,
  p_is_deleted boolean
)
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.contests (
      id,
      created_at,
      organizer_id,
      name,
      description,
      date_time,
      works_submission_from,
      works_submission_to,
      place_id,
      contest_status,
      images_urls,
      token,
      voting_form_id,
      is_deleted
    )
    VALUES (
      p_id,
      p_created_at,
      p_organizer_id,
      p_name,
      p_description,
      p_date_time,
      p_works_submission_from,
      p_works_submission_to,
      p_place_id,
      p_contest_status,
      p_images_urls,
      p_token,
      p_voting_form_id,
      p_is_deleted
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- UPDATE CONTEST BY ID
CREATE OR REPLACE FUNCTION public.update_contest (
  p_id uuid,
  p_created_at timestamptz,
  p_organizer_id uuid,
  p_name varchar,
  p_description varchar,
  p_date_time timestamptz,
  p_works_submission_from timestamptz,
  p_works_submission_to timestamptz,
  p_place_id uuid,
  p_contest_status public.contest_status,
  p_images_urls text[],
  p_token varchar,
  p_voting_form_id uuid,
  p_is_deleted boolean
)
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    UPDATE public.contests
    SET
      created_at = p_created_at,
      organizer_id = p_organizer_id,
      name = p_name,
      description = p_description,
      date_time = p_date_time,
      works_submission_from = p_works_submission_from,
      works_submission_to = p_works_submission_to,
      place_id = p_place_id,
      contest_status = p_contest_status,
      images_urls = p_images_urls,
      token = p_token,
      voting_form_id = p_voting_form_id,
      is_deleted = p_is_deleted
    WHERE contests.id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- DELETE CONTEST BY ID
CREATE OR REPLACE FUNCTION public.delete_contest_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.contests
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTEST BY ID
CREATE OR REPLACE FUNCTION public.get_contest_by_id(
  p_id uuid
)
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.contests
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET ALL CONTESTS
CREATE OR REPLACE FUNCTION public.get_all_contests()
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.contests
    WHERE true;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTESTS BY ORGANIZER ID
CREATE OR REPLACE FUNCTION public.get_contests_by_organizer_id(
    p_organizer_id uuid
)
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.contests
    WHERE organizer_id = p_organizer_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET CONTEST BY TOKEN
CREATE OR REPLACE FUNCTION public.get_contest_by_token(
  p_token varchar
)
RETURNS SETOF public.contests AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.contests
    WHERE token = p_token;
END;
$$ LANGUAGE plpgsql SECURITY definer;