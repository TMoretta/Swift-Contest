-- JUROR GET JOINED CONTESTS
CREATE OR REPLACE FUNCTION juror_get_joined_contests (
  p_juror_id uuid
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
    JOIN jurations jura ON jura.contest_id = cont.id AND jura.juror_status = 'joined'
    WHERE jura.juror_id = p_juror_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting joined contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR JOIN CONTEST
CREATE OR REPLACE FUNCTION juror_join_contest(
  p_juror_id uuid,
  p_token char
)
RETURNS void AS $$
DECLARE
  v_invitation invitations;
  v_contest_id uuid;
  v_juration jurations;
BEGIN

  SELECT * INTO STRICT v_invitation
  FROM invitations
  WHERE token = p_token AND member_role = 'juror';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No invitation found with the provided token';
  END IF;

  SELECT id INTO STRICT v_contest_id
  FROM contests
  WHERE id = v_invitation.contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No contest found with the provided invitation';
  END IF;

  SELECT * INTO v_juration FROM jurations
  WHERE contest_id = v_contest_id AND juror_id = p_juror_id
  LIMIT 1;

  IF FOUND THEN
    IF (v_juration.juror_status = 'joined') THEN
      RAISE EXCEPTION 'You are already a juror in this contest';
    ELSE
      UPDATE jurations
      SET juror_status = 'joined'
      WHERE id = v_juration.id;
    END IF;
  ELSE
    INSERT INTO jurations (
      id,
      created_at,
      contest_id,
      juror_id,
      juror_status
    ) VALUES (
      gen_random_uuid(),
      now(),
      v_contest_id,
      p_juror_id,
      'joined'
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