-- PARTICIPANT GET JOINED CONTESTS
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
BEGIN
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
    RAISE EXCEPTION 'An error occurred while getting joined contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT JOIN CONTEST
CREATE OR REPLACE FUNCTION participant_join_contest(
  p_participant_id uuid,
  p_token varchar
)
RETURNS void AS $$
DECLARE
  v_invitation invitations;
  v_contest_id uuid;
  v_participation participations;
BEGIN

  SELECT * INTO STRICT v_invitation
  FROM invitations
  WHERE token = p_token AND member_role = 'participant';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No invitation found with the provided token';
  END IF;

  SELECT id INTO STRICT v_contest_id
  FROM contests
  WHERE id = v_invitation.contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No contest found with the provided invitation';
  END IF;

  SELECT * INTO v_participation FROM participations
  WHERE contest_id = v_contest_id AND participant_id = p_participant_id
  LIMIT 1;

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
      id,
      created_at,
      contest_id,
      participant_id,
      participant_status,
      invitation_email,
      has_submitted
    ) VALUES (
      gen_random_uuid(),
      now(),
      v_contest_id,
      p_participant_id,
      'joined',
      v_invitation.email,
      false
    );
  END IF;

  DELETE FROM invitations
  WHERE id = v_invitation.id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while trying to join a contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT GET CONTEST DETAILS
CREATE OR REPLACE FUNCTION participant_get_contest_details (
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
      to_jsonb(c) AS contest,
      to_jsonb(o) AS organizer,
      to_jsonb(p) AS place,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part))
         FROM participations part
         WHERE part.contest_id = c.id
        ), '[]'::jsonb) AS participations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(p))
         FROM profiles p
         JOIN participations part ON p.id = part.participant_id
         WHERE part.contest_id = c.id
        ), '[]'::jsonb) AS participants,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(work))
         FROM works work
         JOIN participations part
          ON work.participation_id = part.id
            AND part.has_submitted = true
            AND part.participant_status = 'joined'
         WHERE part.contest_id = c.id
        ), '[]'::jsonb) AS works,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur))
         FROM jurations jur
         WHERE jur.contest_id = c.id
        ), '[]'::jsonb) AS jurations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(juror))
         FROM profiles juror
         JOIN jurations j ON juror.id = j.juror_id
         WHERE j.contest_id = c.id
        ), '[]'::jsonb) AS jurors,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(inv))
         FROM invitations inv
         WHERE inv.contest_id = c.id
        ), '[]'::jsonb) AS invitations,
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = c.voting_form_id
        ), 'null'::jsonb) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vf_field))
         FROM voting_form_fields vf_field
         WHERE vf_field.voting_form_id = c.voting_form_id
        ), '[]'::jsonb) AS voting_form_fields,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vs))
         FROM voting_sessions vs
         WHERE vs.contest_id = c.id
        ), '[]'::jsonb) AS voting_sessions
    FROM contests c
    JOIN profiles o ON c.organizer_id = o.id
    JOIN places p ON c.place_id = p.id
    WHERE c.id = p_contest_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting contest details';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT GET OWN WORK
CREATE OR REPLACE FUNCTION participant_get_submitted_work(
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
    RAISE EXCEPTION 'No participation found';
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
    RAISE EXCEPTION 'An error occurred while getting the work';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- PARTICIPANT SUBMIT WORK
CREATE OR REPLACE FUNCTION participant_submit_work(
  p_participant_id uuid,
  p_contest_id uuid,
  p_name varchar,
  p_description varchar,
  p_images_urls text[]
)
RETURNS void AS $$
DECLARE
  v_participation participations;
BEGIN

  SELECT * INTO v_participation
  FROM participations
  WHERE contest_id = p_contest_id AND participant_id = p_participant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No participation found';
  END IF;

  IF (v_participation.has_submitted = true) THEN
    RAISE EXCEPTION 'You have already submitted a work';
  END IF;

  INSERT INTO works (id, created_at, participation_id, name, description, images_urls)
  VALUES (gen_random_uuid(), now(), v_participation.id, p_name, p_description, p_images_urls);

  UPDATE participations
  SET has_submitted = true
  WHERE id = v_participation.id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while submitting the work';
END;
$$ LANGUAGE plpgsql SECURITY definer;

