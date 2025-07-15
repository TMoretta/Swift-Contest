-- DELETE ACCOUNT
CREATE OR REPLACE FUNCTION delete_current_account ()
RETURNS void AS $$
DECLARE
  v_current_user_id uuid;
  v_profile profiles;
  v_created_contest_id uuid;
  v_joined_participation participations;
  v_joined_juration jurations;
BEGIN

  v_current_user_id := auth.uid();

  IF (v_current_user_id is null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = v_current_user_id AND deleted_at is null
  ) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- set all created contests as deleted
  FOR v_created_contest_id IN (
    SELECT id
    FROM contests
    WHERE organizer_id = v_profile.id
  ) LOOP
    PERFORM organizer_delete_contest(v_created_contest_id);
  END LOOP;

  -- leave all the contests joined as participant
  FOR v_joined_participation IN (
    SELECT *
    FROM participations
    WHERE participant_id = v_profile.id AND participant_status = 'joined'
  ) LOOP
    PERFORM participant_leave_contest(v_joined_participation.contest_id, v_joined_participation.participant_id);
  END LOOP;

  -- leave all the contests joined as juror
  FOR v_joined_juration IN (
    SELECT *
    FROM jurations
    WHERE juror_id = v_profile.id AND juror_status = 'joined'
  ) LOOP
    PERFORM juror_leave_contest(v_joined_juration.contest_id, v_joined_juration.juror_id);
  END LOOP;

  UPDATE profiles
  SET deleted_at = now()
  WHERE user_id = v_current_user_id
  RETURNING * INTO v_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting account';
  END IF;

  UPDATE auth.users
  SET
    deleted_at = now(),
    email = email || '.deleted_' || to_char(now(), 'YYYYMMDD_HH24MI') || '_' || id
   WHERE id = v_current_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting account';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;