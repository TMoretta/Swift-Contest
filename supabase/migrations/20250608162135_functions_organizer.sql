-- ORGANIZER GET CREATED CONTESTS
CREATE OR REPLACE FUNCTION organizer_get_created_contests (
  p_organizer_id uuid
)
RETURNS TABLE (
  contest jsonb,
  organizer jsonb,
  place jsonb,
  participations jsonb,
  jurations jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      to_jsonb(cont) AS contest,
      to_jsonb(org) AS organizer,
      to_jsonb(pla) AS place,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(par))
        FROM participations par
        WHERE par.contest_id = cont.id
      ), '[]'::jsonb) AS participations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur))
        FROM jurations jur
        WHERE jur.contest_id = cont.id
      ), '[]'::jsonb) AS jurations
    FROM contests cont
    JOIN profiles org ON cont.organizer_id = org.id
    JOIN places pla ON cont.place_id = pla.id
    WHERE cont.organizer_id = p_organizer_id AND cont.deleted_at is null
    ORDER BY cont.created_at DESC;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting created contests';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER GET CONTEST DETAILS
CREATE OR REPLACE FUNCTION organizer_get_contest_details (
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
        (SELECT jsonb_agg(to_jsonb(part))
         FROM participations part
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
        (SELECT jsonb_agg(to_jsonb(jura))
         FROM jurations jura
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(juro))
         FROM profiles juro
         JOIN jurations jura ON juro.id = jura.juror_id
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurors,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(inv))
         FROM invitations inv
         WHERE inv.contest_id = cont.id
        ), '[]'::jsonb) AS invitations,
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = cont.voting_form_id
        ), 'null'::jsonb) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vf_field))
         FROM voting_form_fields vf_field
         WHERE vf_field.voting_form_id = cont.voting_form_id
        ), '[]'::jsonb) AS voting_form_fields,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vs))
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
    RAISE EXCEPTION 'An error occurred while getting contest details';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER CREATE CONTEST
CREATE OR REPLACE FUNCTION organizer_create_contest (
  p_contest contests,
  p_place places,
  p_voting_form voting_forms
)
RETURNS void AS $$
BEGIN

  PERFORM create_place(p_place);
  PERFORM create_voting_form(p_voting_form);
  PERFORM create_contest(p_contest);

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the contest';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER UPDATE VOTING FORM FIELDS
CREATE OR REPLACE FUNCTION organizer_update_voting_form_fields (
  p_voting_form_id uuid,
  p_voting_form_fields voting_form_fields[]
)
RETURNS void AS $$
BEGIN
  DELETE FROM voting_form_fields
  WHERE voting_form_id = p_voting_form_id;

  IF array_length(p_voting_form_fields, 1) IS NOT NULL THEN
    FOR i IN 1..array_length(p_voting_form_fields, 1) LOOP
      PERFORM create_voting_form_field(p_voting_form_fields[i]);
    END LOOP;
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting form';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER INIT VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_init_voting_session (
  p_voting_form voting_forms,
  p_voting_form_fields voting_form_fields[],
  p_place places,
  p_voting_session voting_sessions,
  p_voting_session_participations voting_session_participations[],
  p_voting_session_jurations voting_session_jurations[],
  p_voting_session_exclusions voting_session_exclusions[]
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_session voting_sessions;
BEGIN
  IF EXISTS (
    SELECT 1
    FROM voting_sessions
    WHERE contest_id = p_voting_session.contest_id AND session_status <> 'ended' AND session_status <> 'cancelled'
  ) THEN
    RAISE EXCEPTION 'A voting session is already in progress for this contest';
  END IF;

  PERFORM create_voting_form(p_voting_form);

  FOR i IN 1..array_length(p_voting_form_fields, 1) LOOP
    PERFORM create_voting_form_field(p_voting_form_fields[i]);
  END LOOP;

  IF p_place IS NOT NULL THEN
    PERFORM create_place(p_place);
  END IF;

  SELECT * INTO STRICT v_voting_session
  FROM create_voting_session(p_voting_session);

  FOR i IN 1..array_length(p_voting_session_participations, 1) LOOP
    PERFORM create_voting_session_participation(p_voting_session_participations[i]);
  END LOOP;

  FOR i IN 1..array_length(p_voting_session_jurations, 1) LOOP
    PERFORM create_voting_session_juration(p_voting_session_jurations[i]);
  END LOOP;

  IF array_length(p_voting_session_exclusions, 1) IS NOT NULL THEN
    FOR i IN 1..array_length(p_voting_session_exclusions, 1) LOOP
      PERFORM create_voting_session_exclusion(p_voting_session_exclusions[i]);
    END LOOP;
  END IF;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while initializing the voting session';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER START VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_start_voting_session (
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_work_timer interval;
  v_job_name text := 'voting_session_' || p_voting_session_id;
BEGIN
  SELECT work_timer * INTERVAL '1 seconds'
  INTO v_work_timer
  FROM voting_sessions
  WHERE id = p_voting_session_id;

  UPDATE voting_sessions
  SET
    session_status = 'work'::voting_session_status,
    current_participant_index = 0,
    current_step_deadline = now() + v_work_timer
  WHERE id = p_voting_session_id;

  -- Schedule a cron job for this session
  PERFORM cron.schedule(
    v_job_name,
    '1 seconds',
    format($fmt$ SELECT organizer_advance_voting_session('%s'); $fmt$,
      p_voting_session_id
    )
  );

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while starting the session';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER ADVANCE VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_advance_voting_session (
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_session voting_sessions;
  v_next_index int;
  v_next_status text;
  v_delay interval;
  v_count int;
  v_job_name text;
  v_timers record;
BEGIN

  SELECT *
  INTO v_session
  FROM voting_sessions
  WHERE id = p_voting_session_id;

  RAISE NOTICE 'Current status: %', v_session.session_status;

  IF v_session.session_status <> 'ended' AND v_session.session_status <> 'cancelled' AND v_session.current_step_deadline <= now() THEN
    -- Prendo i timer dalla tabella principale
    SELECT work_timer, intermission_timer, review_timer
    INTO v_timers
    FROM voting_sessions
    WHERE id = p_voting_session_id;

    -- Numero di partecipanti
    SELECT COUNT(*) INTO v_count
    FROM voting_session_participations
    WHERE voting_session_id = v_session.id AND is_excluded = false;

    -- Diversifico per step corrente
    IF v_session.session_status = 'work' THEN
      -- Work finito → intermission su *stesso* indice
      v_next_status := 'intermission';
      v_delay     := v_timers.intermission_timer  * INTERVAL '1 seconds';
      v_next_index  := v_session.current_participant_index;

    ELSIF v_session.session_status = 'intermission' THEN
      -- Intermission finito → se ci sono altri partecipanti, vai a work+1,
      -- altrimenti entri in review
      IF (v_session.current_participant_index + 1) < v_count THEN
        v_next_status := 'work';
        v_delay     := v_timers.work_timer  * INTERVAL '1 seconds';
        v_next_index  := v_session.current_participant_index + 1;
      ELSE
        v_next_status := 'review';
        v_delay     := v_timers.review_timer * INTERVAL '1 seconds';
        v_next_index  := NULL;
      END IF;

    ELSIF v_session.session_status = 'review' THEN
      -- Review finita → ended
      v_next_status := 'ended';
      v_delay     := NULL;
      v_next_index  := NULL;

    ELSE
      -- (non dovrebbe capitare) fallback alla fine
      v_next_status := 'cancelled';
      v_delay     := NULL;
      v_next_index  := NULL;
    END IF;

    IF v_next_status = 'cancelled' THEN
      v_job_name := 'voting_session_' || v_session.id;
      PERFORM cron.unschedule(v_job_name);
      UPDATE voting_sessions
      SET
        session_status = v_next_status::voting_session_status,
        current_participant_index = NULL,
        current_step_deadline = NULL
      WHERE id = v_session.id;
    END IF;

    -- Se passo a END, unschedule + update
    IF v_next_status = 'ended' THEN
      v_job_name := 'voting_session_' || v_session.id;
      PERFORM cron.unschedule(v_job_name);
      UPDATE voting_sessions
      SET
        session_status = v_next_status::voting_session_status,
        current_participant_index = NULL,
        current_step_deadline = NULL
      WHERE id = v_session.id;
    ELSE
      -- Altrimenti aggiorno lo stato
      UPDATE voting_sessions
      SET
        current_participant_index = v_next_index,
        session_status = v_next_status::voting_session_status,
        current_step_deadline = now() + v_delay
      WHERE id = v_session.id;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER END VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_end_voting_session(
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_' || p_voting_session_id;
  v_job_exists boolean;
BEGIN

  SELECT EXISTS(
    SELECT 1
    FROM cron.job
    WHERE jobname = v_job_name
  ) INTO v_job_exists;

  IF v_job_exists THEN
    PERFORM cron.unschedule(v_job_name);
  END IF;

  UPDATE voting_sessions
  SET
    session_status = 'ended'::voting_session_status,
    current_participant_index = NULL,
    current_step_deadline = NULL
  WHERE id = p_voting_session_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while ending the session';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER CANCEL VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_cancel_voting_session (
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_' || p_voting_session_id;
  v_job_exists boolean;
BEGIN

  SELECT EXISTS(
    SELECT 1
    FROM cron.job
    WHERE jobname = v_job_name
  ) INTO v_job_exists;

  IF v_job_exists THEN
    PERFORM cron.unschedule(v_job_name);
  END IF;

  UPDATE voting_sessions
  SET
    session_status = 'cancelled'::voting_session_status,
    current_participant_index = NULL,
    current_step_deadline = NULL
  WHERE id = p_voting_session_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while cancelling the session';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER DELETE INVITATION
CREATE OR REPLACE FUNCTION organizer_delete_invitation (
  p_invitation_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM invitations
  WHERE id = p_invitation_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the invitation';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER GET VOTING SESSION DETAILS
CREATE OR REPLACE FUNCTION organizer_get_voting_session_details (
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
    JOIN contests c
      ON ses.contest_id = c.id
    WHERE ses.id = p_voting_session_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting voting session details';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION organizer_edit_voting_session_name (
  p_voting_session_id uuid,
  p_name varchar
)
RETURNS void AS $$
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id
  ) THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

  UPDATE voting_sessions
  SET name = p_name
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while editing the voting session name';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while editing the voting session name';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ORGANIZER REMOVE PARTICIPANT
CREATE OR REPLACE FUNCTION organizer_remove_participant (
  p_participation_id uuid,
  p_message_title text,
  p_message_body text
)
RETURNS void as $$
DECLARE
  v_participant_id uuid;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM participations
    WHERE id = p_participation_id AND participant_status = 'joined'
  ) THEN
    RAISE EXCEPTION 'Participant not found or not joined';
  END IF;

  SELECT participant_id FROM participations INTO v_participant_id
  WHERE id = p_participation_id;

  INSERT INTO messages (id, created_at, profile_id, title, body, is_read)
  VALUES (uuid_generate_v4(), now(), v_participant_id, p_message_title, p_message_body, false);

  UPDATE participations
  SET participant_status = 'out'
  WHERE id = p_participation_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while removing the participant';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while removing the participant';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER REMOVE JUROR
CREATE OR REPLACE FUNCTION organizer_remove_juror (
  p_juration_id uuid,
  p_message_title text,
  p_message_body text
)
RETURNS void as $$
DECLARE
  v_juror_id uuid;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM jurations
    WHERE id = p_juration_id AND juror_status = 'joined'
  ) THEN
    RAISE EXCEPTION 'Juror not found or not joined';
  END IF;

  SELECT juror_id FROM jurations INTO v_juror_id
  WHERE id = p_juration_id;

  INSERT INTO messages (id, created_at, profile_id, title, body, is_read)
  VALUES (uuid_generate_v4(), now(), v_juror_id, p_message_title, p_message_body, false);

  UPDATE jurations
  SET juror_status = 'out'
  WHERE id = p_juration_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while removing the juror';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while removing the juror';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER DELETE CONTEST
CREATE OR REPLACE FUNCTION organizer_delete_contest (
  p_contest_id uuid
)
RETURNS void AS $$
DECLARE
  v_contest contests;
  v_organizer profiles;
  v_participation participations;
  v_juration jurations;
  v_message_title text;
  v_message_body text;
BEGIN

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  SELECT * INTO v_organizer
  FROM profiles
  WHERE id = v_contest.organizer_id;

  v_message_title := 'Deleted contest';
  v_message_body  := format(
      '"%s" has been deleted by the organizer "%s"',
      v_contest.name,
      v_organizer.full_name
    );

  -- Invio messaggi a tutti i partecipanti
  FOR v_participation IN
    SELECT *
    FROM participations
    WHERE contest_id = p_contest_id
  LOOP
    INSERT INTO messages (
      id, created_at, profile_id, title, body
    ) VALUES (
      uuid_generate_v4(),
      now(),
      v_participation.participant_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  -- Invio messaggi a tutti i giurati
  FOR v_juration IN
    SELECT *
    FROM jurations
    WHERE contest_id = p_contest_id
  LOOP
    INSERT INTO messages (
      id, created_at, profile_id, title, body
    ) VALUES (
      uuid_generate_v4(),
      now(),
      v_juration.juror_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  UPDATE contests
  SET deleted_at = now()
  WHERE id = p_contest_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER GET VOTING FORM BUNDLE
CREATE OR REPLACE FUNCTION organizer_get_voting_form_bundle (
  p_voting_form_id uuid
)
RETURNS TABLE (
  voting_form jsonb,
  voting_form_fields jsonb
) AS $$
BEGIN

  RETURN QUERY
    SELECT
      to_jsonb(form) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(field) ORDER BY field.order_index)
         FROM voting_form_fields field
         WHERE field.voting_form_id = p_voting_form_id
        ), '[]'::jsonb) AS voting_form_fields
    FROM voting_forms form
    WHERE form.id = p_voting_form_id
    LIMIT 1;

END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER GET VOTING SESSION RESULT DETAILS
CREATE OR REPLACE FUNCTION organizer_get_voting_session_raw_juror_votes (
  p_voting_session_id uuid
)
RETURNS TABLE (
  juror_votings jsonb,
  juror_votes jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      -- 2) tutti i juror_votings legati a quelle juration
      COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(jv))
          FROM juror_votings jv
          JOIN voting_session_jurations vsj
            ON jv.voting_session_juration_id = vsj.id
          WHERE vsj.voting_session_id = p_voting_session_id
        ),
        '[]'::jsonb
      ),
      -- 3) tutti i juror_votes legati ai juror_votings di quella sessione
      COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(jv2))
          FROM juror_votes jv2
          JOIN juror_votings jv
            ON jv2.juror_voting_id = jv.id
          JOIN voting_session_jurations vsj2
            ON jv.voting_session_juration_id = vsj2.id
          WHERE vsj2.voting_session_id = p_voting_session_id
        ),
        '[]'::jsonb
      );

END;
$$ LANGUAGE plpgsql SECURITY definer;






















