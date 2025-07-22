--region ADMIN GET ALL USERS
CREATE OR REPLACE FUNCTION admin_get_all_users ()
RETURNS SETOF auth.users AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM auth.users;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET ALL PROFILES
CREATE OR REPLACE FUNCTION admin_get_all_profiles ()
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM profiles;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET USER BY ID
CREATE OR REPLACE FUNCTION admin_get_user_by_id (
  p_user_id uuid
)
RETURNS auth.users AS $$
DECLARE
  v_user auth.users;
BEGIN
  SELECT * INTO v_user
  FROM auth.users
  WHERE id = p_user_id
  LIMIT 1;

  RETURN v_user;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET PROFILE BY ID
CREATE OR REPLACE FUNCTION admin_get_profile_by_user_id (
  p_user_id uuid
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id
  LIMIT 1;

  RETURN v_profile;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET CREATED CONTESTS
CREATE OR REPLACE FUNCTION admin_get_user_created_contests (
  p_user_id uuid
)
RETURNS SETOF contests AS $$
DECLARE
  v_profile profiles;
BEGIN

  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id
  LIMIT 1;

  RETURN QUERY
    SELECT *
    FROM contests
    WHERE organizer_id = v_profile.id;

END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET JOINED CONTESTS AS PARTICIPANT
CREATE OR REPLACE FUNCTION admin_get_user_joined_contests_as_participant (
  p_user_id uuid
)
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT c.*
    FROM profiles pr
    JOIN participations p ON p.participant_id = pr.id
    JOIN contests c ON c.id = p.contest_id
    WHERE pr.user_id = p_user_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET JOINED CONTESTS AS JUROR
CREATE OR REPLACE FUNCTION admin_get_user_joined_contests_as_juror (
  p_user_id uuid
)
RETURNS SETOF contests AS $$
BEGIN
  RETURN QUERY
    SELECT c.*
    FROM profiles pr
    JOIN jurations j ON j.juror_id = pr.id
    JOIN contests c ON c.id = j.contest_id
    WHERE pr.user_id = p_user_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;


--region ADMIN GET PLACE BY ID
CREATE OR REPLACE FUNCTION admin_get_place_by_id (
  p_place_id uuid
)
RETURNS places AS $$
DECLARE
  v_place places;
BEGIN
  SELECT * INTO v_place
  FROM places
  WHERE id = p_place_id
  LIMIT 1;

  RETURN v_place;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET VOTING FORM BY ID
CREATE OR REPLACE FUNCTION admin_get_voting_form_by_id (
  p_voting_form_id uuid
)
RETURNS voting_forms AS $$
DECLARE
  v_voting_form voting_forms;
BEGIN
  SELECT * INTO v_voting_form
  FROM voting_forms
  WHERE id = p_voting_form_id
  LIMIT 1;

  RETURN v_voting_form;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET VOTING FORM FIELDS BY VOTING FORM ID
CREATE OR REPLACE FUNCTION admin_get_voting_form_fields_by_voting_form_id (
  p_voting_form_id uuid
)
RETURNS SETOF voting_form_fields AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_form_fields
    WHERE voting_form_id = p_voting_form_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN DELETE CONTEST BY ID
CREATE OR REPLACE FUNCTION admin_delete_contest_by_id (
  p_contest_id uuid,
  p_reason text DEFAULT null
)
RETURNS bool AS $$
DECLARE
  v_contest contests;
  v_participation participations;
  v_juration jurations;
  v_message_title text;
  v_message_body text;
BEGIN

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  v_message_title := 'Contest deleted';
  IF (p_reason is not null) THEN
    v_message_body := format('"%s" has been deleted by the admin.\nReason: %s', v_contest.name, p_reason);
  ELSE
    v_message_body := format('"%s" has been deleted by the admin', v_contest.name);
  END IF;

  INSERT INTO messages (profile_id, title, body)
  VALUES (v_contest.organizer_id, v_message_title, v_message_body);

  FOR v_participation IN
    SELECT *
    FROM participations
    WHERE contest_id = p_contest_id AND participant_status = 'joined'
  LOOP
    INSERT INTO messages (profile_id, title, body)
    VALUES (
      v_participation.participant_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  -- Invio messaggi a tutti i giurati
  FOR v_juration IN
    SELECT *
    FROM jurations
    WHERE contest_id = p_contest_id AND juror_status = 'joined'
  LOOP
    INSERT INTO messages (profile_id, title, body)
    VALUES (
      v_juration.juror_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  UPDATE contests
  SET
    contest_status = 'deleted',
    deleted_at = now()
  WHERE id = p_contest_id;

  DELETE FROM invitations
  WHERE contest_id = p_contest_id;

  RETURN true;

END;
$$ LANGUAGE plpgsql SECURITY definer;

--region admin_delete_user_by_id
CREATE OR REPLACE FUNCTION admin_delete_user_by_id (
  p_user_id uuid
)
RETURNS void AS $$
DECLARE
  v_profile profiles;
  v_created_contest_id uuid;
BEGIN

  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id;

  FOR v_created_contest_id IN (
    SELECT id
    FROM contests
    WHERE organizer_id = v_profile.id
  ) LOOP
    PERFORM admin_delete_contest_by_id(v_created_contest_id);
  END LOOP;

  UPDATE profiles
  SET deleted_at = now()
  WHERE user_id = p_user_id
  RETURNING * INTO v_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting account';
  END IF;

  UPDATE auth.users
  SET
    deleted_at = now(),
    email = email || '.deleted_' || to_char(now(), 'YYYYMMDD_HH24MI') || '_' || id
   WHERE id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting account';
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY definer;

--region admin_ban_user_by_id
CREATE OR REPLACE FUNCTION admin_ban_user_by_id (
  p_user_id uuid
)
RETURNS void AS $$
DECLARE
  v_profile profiles;
BEGIN

  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id;

  UPDATE profiles
  SET deleted_at = now()
  WHERE user_id = p_user_id
  RETURNING * INTO v_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while banning account';
  END IF;

  UPDATE auth.users
  SET
    banned_until = now()
   WHERE id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while banning account';
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE FUNCTION admin_get_user_contests (
  p_user_id uuid
)
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
  contest_status contest_status,
  images_urls text[],
  token varchar,
  voting_form_id uuid,
  deleted_at timestamptz
) AS $$
DECLARE
  v_profile profiles;
BEGIN
  -- Trova il profilo dell'utente
  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found for user_id %', p_user_id;
  END IF;

  -- Contest creati (organizer)
  RETURN QUERY
  SELECT
    'organizer'::contest_role, c.*
  FROM contests c
  WHERE c.organizer_id = v_profile.id;

  -- Contest partecipati
  RETURN QUERY
  SELECT
    'participant'::contest_role, c.*
  FROM participations p
  JOIN contests c ON c.id = p.contest_id
  WHERE p.participant_id = v_profile.id;

  -- Contest giurato
  RETURN QUERY
  SELECT
    'juror'::contest_role, c.*
  FROM jurations j
  JOIN contests c ON c.id = j.contest_id
  WHERE j.juror_id = v_profile.id;

END;
$$ LANGUAGE plpgsql SECURITY definer;



















