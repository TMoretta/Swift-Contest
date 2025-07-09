--region PARTICIPANT GET JOINED CONTESTS
CREATE OR REPLACE FUNCTION participant_get_joined_contests (
  p_participant_id uuid
)
RETURNS TABLE (
  contest jsonb,
  organizer jsonb,
  place jsonb,
  participations jsonb,
  jurations jsonb
) AS $$
DECLARE
DECLARE
  v_user_id uuid;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT u.id INTO v_user_id
  FROM auth.users u
  JOIN profiles p ON p.user_id = u.id
  WHERE p.id = p_participant_id
  LIMIT 1;

  IF (auth.uid() <> v_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  RETURN QUERY
    SELECT
      to_jsonb(cont),
      to_jsonb(org),
      to_jsonb(pla),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part))
        FROM participations part
        WHERE part.contest_id = cont.id
      ), '[]'::jsonb),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur))
        FROM jurations jur
        WHERE jur.contest_id = cont.id
      ), '[]'::jsonb)
    FROM contests cont
    JOIN places pla ON cont.place_id = pla.id
    JOIN profiles org ON cont.organizer_id = org.id
    JOIN participations par ON par.contest_id = cont.id AND par.participant_status = 'joined'
    WHERE par.participant_id = p_participant_id
    ORDER BY cont.created_at DESC;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region PARTICIPANT GET CONTEST DETAILS
CREATE OR REPLACE FUNCTION get_contest_details (
  p_contest_id uuid
)
RETURNS TABLE (
  contest jsonb,
  organizer jsonb,
  place jsonb,
  participations jsonb,
  participants jsonb,
  works jsonb,
  jurations jsonb,
  jurors jsonb,
  invitations jsonb,
  voting_form jsonb,
  voting_form_fields jsonb,
  voting_sessions jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      to_jsonb(cont) AS contest,
      to_jsonb(org) AS organizer,
      to_jsonb(pla) AS place,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part) ORDER BY pro.full_name ASC)
         FROM participations part
         JOIN profiles pro ON pro.id = part.participant_id
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS participations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(par))
         FROM profiles par
         JOIN participations part ON par.id = part.participant_id
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS participants,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(wor))
         FROM works wor
         JOIN participations part
          ON wor.participation_id = part.id
            AND part.has_submitted = true
            AND part.participant_status = 'joined'
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS works,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jura) ORDER BY pro.full_name ASC)
         FROM jurations jura
         JOIN profiles pro ON pro.id = jura.juror_id
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(juro))
         FROM profiles juro
         JOIN jurations jura ON juro.id = jura.juror_id
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurors,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(inv) ORDER BY inv.created_at DESC)
         FROM invitations inv
         WHERE inv.contest_id = cont.id
        ), '[]'::jsonb) AS invitations,
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = cont.voting_form_id
        ), 'null'::jsonb) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vf_field) ORDER BY vf_field.order_index ASC)
         FROM voting_form_fields vf_field
         WHERE vf_field.voting_form_id = cont.voting_form_id
        ), '[]'::jsonb) AS voting_form_fields,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vs) ORDER BY vs.created_at DESC)
         FROM voting_sessions vs
         WHERE vs.contest_id = cont.id
        ), '[]'::jsonb) AS voting_sessions
    FROM contests cont
    JOIN profiles org ON cont.organizer_id = org.id
    JOIN places pla ON cont.place_id = pla.id
    WHERE cont.id = p_contest_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region PARTICIPANT JOIN CONTEST
CREATE OR REPLACE FUNCTION participant_join_contest(
  p_participant_id uuid,
  p_token varchar
)
RETURNS void AS $$
DECLARE
  v_user_id uuid;
  v_invitation invitations;
  v_contest contests;
  v_participation participations;
  v_participant profiles;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT u.id INTO v_user_id
  FROM auth.users u
  JOIN profiles p ON p.user_id = u.id
  WHERE p.id = p_participant_id
  LIMIT 1;

  IF (auth.uid() <> v_user_id) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the account owner';
  END IF;

  SELECT * INTO v_invitation
  FROM invitations
  WHERE token = p_token AND member_role = 'participant';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No invitation found with the provided token';
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = v_invitation.contest_id AND deleted_at is null;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No contest found with the provided invitation';
  END IF;

  SELECT * INTO v_participation
  FROM participations
  WHERE contest_id = v_contest.id AND participant_id = p_participant_id;

  IF FOUND THEN
    IF (v_participation.participant_status = 'joined') THEN
      RAISE EXCEPTION 'You are already a participant in this contest';
    ELSE
      UPDATE participations
      SET
        participant_status = 'joined',
        invitation_email = v_invitation.email
      WHERE id = v_participation.id;
    END IF;
  ELSE
    INSERT INTO participations (
      contest_id,
      participant_id,
      participant_status,
      invitation_email
    ) VALUES (
      v_contest.id,
      p_participant_id,
      'joined',
      v_invitation.email
    );
  END IF;

  DELETE FROM invitations
  WHERE id = v_invitation.id;

  SELECT * INTO v_participant
  FROM profiles
  WHERE id = p_participant_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (v_contest.organizer_id, 'Participant join', format('"%s" joined the contest "%s"',v_participant.full_name, v_contest.name));

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while trying to join a contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT LEAVE CONTEST
CREATE OR REPLACE FUNCTION participant_leave_contest (
  p_contest_id uuid,
  p_participant_id uuid
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_participant profiles;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM participations
    WHERE contest_id = p_contest_id AND participant_id = p_participant_id
  ) THEN
    RAISE EXCEPTION 'Participant not found';
  END IF;

  IF EXISTS (
    SELECT 1 FROM participations
    WHERE contest_id = p_contest_id AND participant_id = p_participant_id AND participant_status = 'out'
  ) THEN
    RAISE EXCEPTION 'Participant is already out from the contest';
  END IF;

  UPDATE participations
  SET participant_status = 'out'
  WHERE contest_id = p_contest_id AND participant_id = p_participant_id;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  SELECT * INTO v_participant
  FROM profiles
  WHERE id = p_participant_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (v_contest.organizer_id, 'Participant leave', format('"%s" leave the contest "%s"',v_participant.full_name, v_contest.name));

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT GET OWN WORK
CREATE OR REPLACE FUNCTION participant_get_submitted_work (
  p_contest_id uuid,
  p_participant_id uuid
)
RETURNS SETOF works AS $$
DECLARE
  v_participation participations;
BEGIN

  SELECT * INTO v_participation
  FROM participations
  WHERE contest_id = p_contest_id AND participant_id = p_participant_id
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No participant found';
  END IF;

  RETURN QUERY
    SELECT *
    FROM works
    WHERE participation_id = v_participation.id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT SUBMIT WORK
CREATE OR REPLACE FUNCTION participant_submit_work(
  p_participant_id uuid,
  p_contest_id uuid,
  p_name varchar,
  p_description varchar,
  p_images_urls text[],
  p_file_url text
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_participation participations;
  v_participant profiles;
BEGIN

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No contest found';
  END IF;

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'Operation not allowed. The contest has been deleted';
  END IF;

  IF (v_contest.contest_status <> 'participationPhase') THEN
    RAISE EXCEPTION 'Operation not allowed. The contest is not in participation phase';
  END IF;

  SELECT * INTO v_participation
  FROM participations
  WHERE contest_id = p_contest_id AND participant_id = p_participant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No participation found';
  END IF;

  IF (v_participation.has_submitted = true) THEN
    RAISE EXCEPTION 'You have already submitted a work';
  END IF;

  INSERT INTO works (participation_id, name, description, images_urls, file_url)
  VALUES (v_participation.id, p_name, p_description, p_images_urls, p_file_url);

  UPDATE participations
  SET has_submitted = true
  WHERE id = v_participation.id;

  SELECT * INTO v_participant
  FROM profiles
  WHERE id = p_participant_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (
    v_contest.organizer_id,
    'Work submission',
    format('"%s" submitted a work for the contest "%s"', v_participant.full_name, v_contest.name)
  );

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

