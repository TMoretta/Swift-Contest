-- Create a composite type to represent a user account for admin purposes.
-- This combines relevant fields from auth.users and public.profiles.
CREATE TYPE public.admin_account_details AS (
  id uuid,
  email varchar,
  full_name varchar,
  pref_role contest_role,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  banned_until timestamptz,
  is_anonymous boolean
);

--region ADMIN GET ALL ACCOUNTS
CREATE OR REPLACE FUNCTION admin_get_all_accounts()
RETURNS SETOF public.admin_account_details
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  IF session_user <> 'retool' THEN
    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
  END IF;

  RETURN QUERY
    SELECT
      u.id,
      u.email,
      p.full_name,
      p.pref_role,
      u.created_at,
      u.last_sign_in_at,
      u.banned_until,
      u.is_anonymous
    FROM auth.users u
    JOIN public.profiles p ON u.id = p.id
    ORDER BY u.created_at DESC;
END;
$$;

--region ADMIN GET ACCOUNT
CREATE OR REPLACE FUNCTION admin_get_account(p_account_id uuid)
RETURNS public.admin_account_details
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_account public.admin_account_details;
BEGIN
  IF session_user <> 'retool' THEN
    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
  END IF;

  SELECT
    u.id,
    u.email,
    p.full_name,
    p.pref_role,
    u.created_at,
    u.last_sign_in_at,
    u.banned_until,
    u.is_anonymous
  INTO v_account
  FROM auth.users u
  JOIN public.profiles p ON u.id = p.id
  WHERE u.id = p_account_id;

  RETURN v_account;
END;
$$;

--region ADMIN GET ALL CONTESTS FOR AN ACCOUNT
CREATE OR REPLACE FUNCTION admin_get_account_contests(p_account_id uuid)
RETURNS TABLE (
  role contest_role,
  id uuid,
  created_at timestamptz,
  organizer_id uuid,
  name varchar,
  description varchar,
  date_time timestamptz,
  works_submission_start timestamptz,
  works_submission_end timestamptz,
  place_id uuid,
  images_paths text[],
  place_address varchar,
  place_lat float,
  place_lon float
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF session_user <> 'retool' THEN
    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
  END IF;

  -- Contests created by the user (as organizer)
  RETURN QUERY
  SELECT
    'organizer'::contest_role,
    c.id, c.created_at, c.organizer_id, c.name, c.description, c.date_time, c.works_submission_start, c.works_submission_end, c.place_id, c.images_paths,
    pl.address, pl.lat, pl.lon
  FROM contests c
  JOIN places pl ON c.place_id = pl.id
  WHERE c.organizer_id = p_account_id;

  -- Contests joined by the user (as participant)
  RETURN QUERY
  SELECT
    'participant'::contest_role,
    c.id, c.created_at, c.organizer_id, c.name, c.description, c.date_time, c.works_submission_start, c.works_submission_end, c.place_id, c.images_paths,
    pl.address, pl.lat, pl.lon
  FROM participations p
  JOIN contests c ON c.id = p.contest_id
  JOIN places pl ON c.place_id = pl.id
  WHERE p.participant_id = p_account_id;

  -- Contests joined by the user (as juror)
  RETURN QUERY
  SELECT
    'juror'::contest_role,
    c.id, c.created_at, c.organizer_id, c.name, c.description, c.date_time, c.works_submission_start, c.works_submission_end, c.place_id, c.images_paths,
    pl.address, pl.lat, pl.lon
  FROM jurations j
  JOIN contests c ON c.id = j.contest_id
  JOIN places pl ON c.place_id = pl.id
  WHERE j.juror_id = p_account_id;

END;
$$;

--region ADMIN DELETE CONTEST BY ID
CREATE OR REPLACE FUNCTION admin_delete_contest(p_contest_id uuid, p_reason text)
RETURNS bool
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_contest contests;
  v_participation participations;
  v_juration jurations;
  v_message_title text;
  v_message_body text;
BEGIN
  IF session_user <> 'retool' THEN
    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
  END IF;

  -- Fetch contest details to use in notification messages
  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF NOT FOUND THEN
    RAISE WARNING 'Contest with id % not found. Nothing to delete.', p_contest_id;
    RETURN false;
  END IF;

  v_message_title := 'Contest deleted';
  v_message_body := format('The contest "%s" has been deleted by an administrator. Reason: %s', v_contest.name, p_reason);

  -- Notify the organizer
  INSERT INTO messages (account_id, title, body)
  VALUES (v_contest.organizer_id, v_message_title, v_message_body);

  -- Notify all participants
  FOR v_participation IN
    SELECT *
    FROM participations
    WHERE contest_id = p_contest_id
  LOOP
    INSERT INTO messages (account_id, title, body)
    VALUES (
      v_participation.participant_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  -- Notify all jurors
  FOR v_juration IN
    SELECT *
    FROM jurations
    WHERE contest_id = p_contest_id
  LOOP
    INSERT INTO messages (account_id, title, body)
    VALUES (
      v_juration.juror_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  -- Delete the contest. Triggers will handle storage and place cleanup.
  DELETE FROM contests WHERE id = p_contest_id;

  RETURN true;
END;
$$;

----region ADMIN DELETE ACCOUNT
--CREATE OR REPLACE FUNCTION admin_delete_account(p_account_id uuid)
--RETURNS void
--LANGUAGE plpgsql
--SECURITY DEFINER
--SET search_path = public, auth -- Ensure auth schema is in search path for auth.users and auth.admin_delete_user
--AS $$
--DECLARE
--  v_created_contest_id uuid;
--  v_user_full_name varchar(70); -- To store the full name of the user being deleted
--  v_contest_name varchar(50);
--  v_organizer_id uuid;
--BEGIN
--  IF session_user <> 'retool' THEN
--    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
--  END IF;
--
--  -- Get the full name of the user being deleted for notification messages
--  SELECT full_name INTO v_user_full_name
--  FROM public.profiles
--  WHERE id = p_account_id;
--
--  IF NOT FOUND THEN
--    RAISE WARNING 'Profile for account ID % not found. Cannot send specific notifications for participant/juror roles.', p_account_id;
--    v_user_full_name := 'A user'; -- Default if profile not found
--  END IF;
--
--  -- Proactively delete contests organized by the user to trigger notifications.
--  FOR v_created_contest_id IN (
--    SELECT id
--    FROM contests
--    WHERE organizer_id = p_account_id
--  ) LOOP
--    -- Delete with a specific reason.
--    PERFORM admin_delete_contest(v_created_contest_id, 'The organizer''s account has been deleted.');
--  END LOOP;
--
--  -- Handle notifications for contests the user PARTICIPATED in
--  FOR v_organizer_id, v_contest_name IN (
--    SELECT c.organizer_id, c.name
--    FROM participations p
--    JOIN contests c ON c.id = p.contest_id
--    WHERE p.participant_id = p_account_id
--  ) LOOP
--    INSERT INTO messages (account_id, title, body)
--    VALUES (
--      v_organizer_id,
--      'Participant Left Contest',
--      format('The participant "%s" has left your contest "%s" because their account was deleted.', v_user_full_name, v_contest_name)
--    );
--  END LOOP;
--
--  -- Handle notifications for contests the user was a JUROR in
--  FOR v_organizer_id, v_contest_name IN (
--    SELECT c.organizer_id, c.name
--    FROM jurations j
--    JOIN contests c ON c.id = j.contest_id
--    WHERE j.juror_id = p_account_id
--  ) LOOP
--    INSERT INTO messages (account_id, title, body)
--    VALUES (
--      v_organizer_id,
--      'Juror Left Contest',
--      format('The juror "%s" has left your contest "%s" because their account was deleted.', v_user_full_name, v_contest_name)
--    );
--  END LOOP;
--
--  -- Use the built-in Supabase admin function to delete the user.
--  -- This will cascade and delete the user's profile and other related data.
--  PERFORM auth.admin_delete_user(p_account_id);
--END;
--$$;

----region ADMIN BAN ACCOUNT
--CREATE OR REPLACE FUNCTION admin_ban_account(p_account_id uuid)
--RETURNS void
--LANGUAGE plpgsql
--SECURITY DEFINER
--SET search_path = public, auth
--AS $$
--BEGIN
--  IF session_user <> 'retool' THEN
--    RAISE EXCEPTION 'Permission denied: This function can only be called by the admin user.';
--  END IF;
--
--  UPDATE auth.users
--  SET
--    banned_until = 'infinity'
--   WHERE id = p_account_id;
--
--  IF NOT FOUND THEN
--    RAISE EXCEPTION 'User with id % not found. Could not apply ban.', p_account_id;
--  END IF;
--END;
--$$;
