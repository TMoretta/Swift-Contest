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
    WHERE jura.juror_id = p_juror_id
    ORDER BY cont.created_at DESC;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR JOIN CONTEST
CREATE OR REPLACE FUNCTION juror_join_contest (
  p_juror_id uuid,
  p_token varchar
)
RETURNS void AS $$
DECLARE
  v_invitation invitations;
  v_contest contests;
  v_juration jurations;
  v_juror profiles;
BEGIN

  SELECT * INTO v_invitation
  FROM invitations
  WHERE token = p_token AND member_role = 'juror';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No invitation found with the provided token';
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = v_invitation.contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No contest found with the provided invitation';
  END IF;

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'The contest has been deleted';
  END IF;

  SELECT * INTO v_juration
  FROM jurations
  WHERE contest_id = v_contest.id AND juror_id = p_juror_id;

  IF FOUND THEN
    IF (v_juration.juror_status = 'joined') THEN
      RAISE EXCEPTION 'You are already a juror in this contest';
    ELSE
      UPDATE jurations
      SET
        juror_status = 'joined',
        invitation_email = v_invitation.email
      WHERE id = v_juration.id;
    END IF;
  ELSE
    INSERT INTO jurations (
      contest_id,
      juror_id,
      juror_status,
      invitation_email
    ) VALUES (
      v_contest.id,
      p_juror_id,
      'joined',
      v_invitation.email
    );
  END IF;

  DELETE FROM invitations
  WHERE id = v_invitation.id;

  SELECT * INTO v_juror
  FROM profiles
  WHERE id = p_juror_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (v_contest.organizer_id, 'Juror join', format('"%s" joined the contest "%s"',v_juror.full_name, v_contest.name));

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR LEAVE CONTEST
CREATE OR REPLACE FUNCTION juror_leave_contest (
  p_contest_id uuid,
  p_juror_id uuid
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_juror profiles;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM jurations
    WHERE contest_id = p_contest_id AND juror_id = p_juror_id
  ) THEN
    RAISE EXCEPTION 'Juror not found';
  END IF;

  IF EXISTS (
    SELECT 1 FROM jurations
    WHERE contest_id = p_contest_id AND juror_id = p_juror_id AND juror_status = 'out'
  ) THEN
    RAISE EXCEPTION 'Juror is already out from the contest';
  END IF;

  UPDATE jurations
  SET juror_status = 'out'
  WHERE contest_id = p_contest_id AND juror_id = p_juror_id;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  SELECT * INTO v_juror
  FROM profiles
  WHERE id = p_juror_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (v_contest.organizer_id, 'Juror leave', format('"%s" leave the contest "%s"',v_juror.full_name, v_contest.name));

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR SUBMIT VOTES
CREATE OR REPLACE FUNCTION juror_submit_votes (
    p_juror_id uuid,
    p_voting_session_id uuid,
    p_contest_id uuid,
    p_votes_per_participant_map jsonb
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_juration jurations;
  v_voting_session_juration voting_session_jurations;
  v_juror_voting juror_votings;
  v_vot_session_participation_id uuid;
  v_voting_form_field_id uuid;
  v_value int;
  v_votes jsonb;
  v_vote record;
BEGIN

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'Operation not allowed. The contest has been deleted';
  END IF;

  SELECT *
  INTO v_juration
  FROM jurations
  WHERE contest_id = p_contest_id AND juror_id = p_juror_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juror member not found';
  END IF;

  -- Step 2: Retrieve the VotingSessionJuration
  SELECT *
  INTO v_voting_session_juration
  FROM voting_session_jurations
  WHERE voting_session_id = p_voting_session_id AND juration_id = v_juration.id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juror member not found';
  END IF;

  IF (v_voting_session_juration.has_submitted = true) THEN
    RAISE EXCEPTION 'Votes already submitted';
  END IF;

  -- Step 3: Iterate over votesPerParticipantMap
  FOR v_vot_session_participation_id, v_votes
      IN
    SELECT js.key::uuid, js.value
    FROM jsonb_each(p_votes_per_participant_map) AS js(key, value)
  LOOP
    -- Create JurorVoting
    INSERT INTO juror_votings (voting_session_juration_id, voting_session_participation_id)
    VALUES (v_voting_session_juration.id, v_vot_session_participation_id)
    RETURNING id INTO v_juror_voting.id;

    -- Step 4: Iterate over votes for each participation
    FOR v_voting_form_field_id, v_value
        IN
      SELECT js2.key::uuid, (js2.value)::int
      FROM jsonb_each(v_votes) AS js2(key, value)
    LOOP
      -- ora v_voting_form_field_id e v_value sono già valorizzati
      INSERT INTO juror_votes (juror_voting_id, voting_form_field_id, value)
      VALUES (
        v_juror_voting.id,
        v_voting_form_field_id,
        v_value
      );
    END LOOP;
  END LOOP;

  -- Step 5: Update VotingSessionJuration
  UPDATE voting_session_jurations
  SET has_submitted = true
  WHERE id = v_voting_session_juration.id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while submitting';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE FUNCTION juror_access_voting_as_simple_juror (
  p_full_name varchar,
  p_token varchar,
  p_juror_id uuid DEFAULT null
)
RETURNS TABLE (
  simple_juror simple_jurors,
  voting_session voting_sessions
) AS $$
DECLARE
  v_voting_session voting_sessions;
  v_juration jurations;
  v_simple_juror simple_jurors;
  v_voting_session_simple_juror voting_session_simple_jurors;
BEGIN

  SELECT * INTO v_voting_session
  FROM voting_sessions
  WHERE token = p_token;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

  IF (v_voting_session.are_simple_jurors_allowed = false) THEN
    RAISE EXCEPTION 'Simple jurors not allowed for this voting session';
  END IF;

  IF (p_juror_id IS NOT null) THEN
    SELECT * INTO v_juration
    FROM jurations
    WHERE juror_id = p_juror_id;

    IF EXISTS (
      SELECT 1
      FROM voting_session_jurations vsj
      JOIN jurations j ON vsj.juration_id = j.id
      WHERE vsj.voting_session_id = v_voting_session.id AND j.juror_id = p_juror_id AND vsj.has_submitted = false AND v_juration.juror_status = 'joined'
    ) THEN
      RAISE EXCEPTION 'You are a member in this contest, vote as an official juror instead';
    END IF;
  END IF;

  IF (p_juror_id IS NOT null) THEN
    IF EXISTS (
      SELECT 1
      FROM voting_session_jurations vsj
      JOIN jurations j ON vsj.juration_id = j.id
      WHERE vsj.voting_session_id = v_voting_session.id AND j.juror_id = p_juror_id AND vsj.has_submitted = true
    ) THEN
      RAISE EXCEPTION 'You have already voted in this voting session as an official juror';
    END IF;
  END IF;

  INSERT INTO simple_jurors (full_name)
  VALUES (p_full_name)
  RETURNING * INTO v_simple_juror;

  INSERT INTO voting_session_simple_jurors (voting_session_id, simple_juror_id)
  VALUES (v_voting_session.id,v_simple_juror.id);

  RETURN QUERY
    SELECT v_simple_juror, v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- SIMPLE JUROR SUBMIT VOTES
CREATE OR REPLACE FUNCTION simple_juror_submit_votes (
    p_simple_juror_id uuid,
    p_voting_session_id uuid,
    p_contest_id uuid,
    p_votes_per_participant_map jsonb,
    p_juror_id uuid DEFAULT null
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_simple_juror simple_jurors;
  v_voting_session_simple_juror voting_session_simple_jurors;
  v_simple_juror_voting simple_juror_votings;
  v_vot_session_participation_id uuid;
  v_voting_form_field_id uuid;
  v_value int;
  v_votes jsonb;
  v_vote record;
BEGIN

  IF (p_juror_id IS NOT null) THEN
    IF EXISTS (
      SELECT 1
      FROM voting_session_jurations vsj
      JOIN jurations j ON vsj.juration_id = j.id
      WHERE vsj.voting_session_id = p_voting_session_id
        AND j.juror_id = p_juror_id
        AND vsj.has_submitted = true
    ) THEN
      RAISE EXCEPTION 'You have already submitted votes for this voting session as an official juror';
    END IF;
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'Operation not allowed. The contest has been deleted';
  END IF;

  SELECT * INTO v_simple_juror
  FROM simple_jurors
  WHERE id = p_simple_juror_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Simple juror not found';
  END IF;

  -- Step 2: Retrieve the VotingSessionJuration
  SELECT * INTO v_voting_session_simple_juror
  FROM voting_session_simple_jurors
  WHERE voting_session_id = p_voting_session_id AND simple_juror_id = p_simple_juror_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Simple juror not found';
  END IF;

  -- Step 3: Iterate over votesPerParticipantMap
  FOR v_vot_session_participation_id, v_votes IN
    (SELECT js.key::uuid, js.value
    FROM jsonb_each(p_votes_per_participant_map) AS js(key, value))
  LOOP
    -- Create JurorVoting
    INSERT INTO simple_juror_votings (voting_session_simple_juror_id, voting_session_participation_id)
    VALUES (v_voting_session_simple_juror.id, v_vot_session_participation_id)
    RETURNING id INTO v_simple_juror_voting.id;

    -- Step 4: Iterate over votes for each participation
    FOR v_voting_form_field_id, v_value
        IN
      SELECT js2.key::uuid, (js2.value)::int
      FROM jsonb_each(v_votes) AS js2(key, value)
    LOOP
      -- ora v_voting_form_field_id e v_value sono già valorizzati
      INSERT INTO simple_juror_votes (simple_juror_voting_id, voting_form_field_id, value)
      VALUES (
        v_simple_juror_voting.id,
        v_voting_form_field_id,
        v_value
      );
    END LOOP;
  END LOOP;

  -- Step 5: Update VotingSessionJuration
  UPDATE voting_session_simple_jurors
  SET has_submitted = true
  WHERE id = v_voting_session_simple_juror.id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while submitting';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

