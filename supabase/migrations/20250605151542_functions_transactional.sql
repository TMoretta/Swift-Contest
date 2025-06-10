-- JUROR JOIN CONTEST
CREATE OR REPLACE FUNCTION juror_join_contest(
  p_juror_id uuid,
  p_contest_token varchar,
  p_juror_token varchar
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
  v_deleted_invitation_id uuid;
  v_contest_id uuid;
BEGIN

  SELECT * INTO v_contest
  FROM contests
  WHERE token = p_contest_token;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No invitation found with the given credentials';
  END IF;

  IF EXISTS (
    SELECT *
    FROM jurations
    WHERE contest_id = v_contest.id AND juror_id = p_juror_id
  ) THEN
    RAISE EXCEPTION 'Juror already joined';
  END IF;

  DELETE FROM invitations AS inv
  USING contests AS cont
  WHERE cont.id = inv.contest_id
    AND cont.token = p_contest_token
    AND inv.token = p_juror_token
    AND inv.member_role = 'juror'
  RETURNING inv.id, cont.id
  INTO v_deleted_invitation_id, v_contest_id;

  IF v_deleted_invitation_id IS NOT NULL THEN
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
    RETURN v_contest;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR SUBMIT VOTES
CREATE OR REPLACE FUNCTION juror_submit_votes(
    p_juror_id uuid,
    p_voting_session_id uuid,
    p_contest_id uuid,
    p_votes_per_participant_map jsonb
)
RETURNS boolean AS $$
DECLARE
    v_juration jurations;
    v_voting_session_juration voting_session_jurations;
    v_juror_voting juror_votings;
    v_vot_session_participation_id uuid;
    v_voting_form_field_id uuid;
    v_value int;
    v_votes jsonb;
    v_vote RECORD;
BEGIN
  -- Step 1: Retrieve the Juration
  SELECT *
  INTO v_juration
  FROM jurations
  WHERE contest_id = p_contest_id AND juror_id = p_juror_id;

  IF NOT FOUND THEN
    return false;
  END IF;

  -- Step 2: Retrieve the VotingSessionJuration
  SELECT *
  INTO v_voting_session_juration
  FROM voting_session_jurations
  WHERE voting_session_id = p_voting_session_id AND juration_id = v_juration.id;

  IF NOT FOUND THEN
    return false;
  END IF;

  -- Step 3: Iterate over votesPerParticipantMap
  FOR v_vot_session_participation_id, v_votes IN SELECT * FROM jsonb_each(p_votes_per_participant_map) LOOP
    -- Create JurorVoting
    INSERT INTO juror_votings (id, created_at, voting_session_juration_id, voting_session_participation_id)
    VALUES (gen_random_uuid(), now(), v_voting_session_juration.id, v_vot_session_participation_id::uuid)
    RETURNING id INTO v_juror_voting.id;

    -- Step 4: Iterate over votes for each participation
    FOR v_vote IN SELECT * FROM jsonb_each(v_votes) LOOP
      v_voting_form_field_id := (v_vote).key::uuid; -- Assuming the key is the VotingFormField ID
      v_value := (v_vote).value::int; -- Assuming the value is the vote value

      -- Create JurorVote
      INSERT INTO juror_votes (id, created_at, juror_voting_id, voting_form_field_id, value)
      VALUES (gen_random_uuid(), now(), v_juror_voting.id, v_voting_form_field_id, v_value);
    END LOOP;
  END LOOP;

  -- Step 5: Update VotingSessionJuration
  UPDATE voting_session_jurations
  SET has_submitted = true
  WHERE id = v_voting_session_juration.id;

  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
      RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY definer;
