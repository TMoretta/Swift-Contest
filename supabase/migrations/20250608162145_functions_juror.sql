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
    RAISE EXCEPTION 'An error occurred while getting joined contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR GET CONTEST DETAILS
CREATE OR REPLACE FUNCTION juror_get_contest_details (
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

-- JUROR JOIN CONTEST
CREATE OR REPLACE FUNCTION juror_join_contest (
  p_juror_id uuid,
  p_token varchar
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

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'The contest has been deleted';
  END IF;

  SELECT * INTO v_juration FROM jurations
  WHERE contest_id = v_contest_id AND juror_id = p_juror_id
  LIMIT 1;

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
      v_contest_id,
      p_juror_id,
      'joined',
      v_invitation.email
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

-- JUROR GET VOTING SESSION DETAILS
CREATE OR REPLACE FUNCTION juror_get_voting_session_procedure_bundle (
  p_voting_session_id uuid
)
RETURNS TABLE (
  participations jsonb,
  participants jsonb,
  works jsonb,
  jurations jsonb,
  jurors jsonb,
  voting_form jsonb,
  voting_form_fields jsonb,
  voting_session jsonb,
  geo_res_place jsonb,
  voting_session_participations jsonb,
  voting_session_jurations jsonb,
  voting_session_exclusions jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      -- all participations for the contest
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(p))
         FROM participations p
         WHERE p.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS participations,
      -- all participant profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(pr))
         FROM profiles pr
         JOIN participations p ON pr.id = p.participant_id
         WHERE p.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS participants,
      -- submitted works of joined participants
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(w))
         FROM works w
         JOIN participations p ON w.participation_id = p.id
         WHERE p.contest_id = c.id
           AND p.has_submitted = TRUE
           AND p.participant_status = 'joined'
        ),
        '[]'::jsonb
      ) AS works,
      -- all juration records
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(j))
         FROM jurations j
         WHERE j.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS jurations,
      -- juror profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jp))
         FROM profiles jp
         JOIN jurations j ON jp.id = j.juror_id
         WHERE j.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS jurors,
      -- associated voting form
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = c.voting_form_id
        ),
        'null'::jsonb
      ) AS voting_form,
      -- fields of that voting form
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(ff))
         FROM voting_form_fields ff
         WHERE ff.voting_form_id = c.voting_form_id
        ),
        '[]'::jsonb
      ) AS voting_form_fields,
      -- single voting session requested
      to_jsonb(ses) AS voting_session,
      -- optional geographic restriction place (can be null)
      to_jsonb(geopla) AS geo_res_place,
      -- participations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsp))
         FROM voting_session_participations vsp
         WHERE vsp.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_participations,
      -- jurations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsj))
         FROM voting_session_jurations vsj
         WHERE vsj.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_jurations,
      -- exclusions in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vse))
         FROM voting_session_exclusions vse
         WHERE vse.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_exclusions

    FROM voting_sessions ses
    JOIN contests c ON ses.contest_id = c.id
    LEFT JOIN places geopla ON ses.geo_res_place_id = geopla.id
    WHERE ses.id = p_voting_session_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting voting session details';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- JUROR SUBMIT VOTES
CREATE OR REPLACE FUNCTION juror_submit_votes(
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
    RAISE EXCEPTION 'An error occurred while submitting';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- JUROR GET VOTING SESSION GEO RESTRICTION PLACE
CREATE OR REPLACE FUNCTION juror_get_voting_session_geores_place (
  p_place_id uuid
)
RETURNS SETOF places AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM places
    WHERE id = p_place_id
    LIMIT 1;
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
  v_simple_juror simple_jurors;
  v_voting_session_simple_juror voting_session_simple_jurors;
BEGIN

  --todo controllo se simple jurors sono allowed

  SELECT * INTO STRICT v_voting_session
  FROM voting_sessions
  WHERE token = p_token;

  INSERT INTO simple_jurors (full_name)
  VALUES (p_full_name)
  RETURNING * INTO STRICT v_simple_juror;

  INSERT INTO voting_session_simple_jurors (voting_session_id, simple_juror_id)
  VALUES (v_voting_session.id,v_simple_juror.id);

  RETURN QUERY
    SELECT v_simple_juror, v_voting_session;

END;
$$ LANGUAGE plpgsql SECURITY definer;

-- SIMPLE JUROR SUBMIT VOTES
CREATE OR REPLACE FUNCTION simple_juror_submit_votes(
    p_simple_juror_id uuid,
    p_voting_session_id uuid,
    p_contest_id uuid,
    p_votes_per_participant_map jsonb
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

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF (v_contest.deleted_at IS NOT null) THEN
    RAISE EXCEPTION 'Operation not allowed. The contest has been deleted';
  END IF;

  SELECT *
  INTO v_simple_juror
  FROM simple_jurors
  WHERE id = p_simple_juror_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juror member not found';
  END IF;

  -- Step 2: Retrieve the VotingSessionJuration
  SELECT *
  INTO v_voting_session_simple_juror
  FROM voting_session_simple_jurors
  WHERE voting_session_id = p_voting_session_id AND simple_juror_id = p_simple_juror_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Simple juror member not found';
  END IF;

  -- Step 3: Iterate over votesPerParticipantMap
  FOR v_vot_session_participation_id, v_votes
      IN
    SELECT js.key::uuid, js.value
    FROM jsonb_each(p_votes_per_participant_map) AS js(key, value)
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

--EXCEPTION
--  WHEN SQLSTATE 'P0001' THEN
--    RAISE;
--  WHEN OTHERS THEN
--    RAISE EXCEPTION 'An error occurred while submitting';
END;
$$ LANGUAGE plpgsql SECURITY definer;

