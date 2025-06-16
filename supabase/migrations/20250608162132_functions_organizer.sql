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
      to_jsonb(c),
      to_jsonb(o),
      to_jsonb(p),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part))
        FROM participations part
        WHERE part.contest_id = c.id
      ), '[]'::jsonb),
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur))
        FROM jurations jur
        WHERE jur.contest_id = c.id
      ), '[]'::jsonb)
    FROM contests c
    JOIN profiles o ON c.organizer_id = o.id
    JOIN places p ON c.place_id = p.id
    WHERE c.organizer_id = p_organizer_id
    ORDER BY c.created_at DESC;

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
    WHERE c.id = p_contest_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting contest details';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER CREATE CONTEST
CREATE OR REPLACE FUNCTION organizer_create_contest(
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

-- ORGANIZER UPDATE VOTING FORM
CREATE OR REPLACE FUNCTION organizer_update_voting_form_fields(
  p_voting_form_id uuid,
  p_voting_form_fields voting_form_fields[]
)
RETURNS void AS $$
BEGIN
  DELETE FROM voting_form_fields
  WHERE voting_form_id = p_voting_form_id;

  FOR i IN 1..array_length(p_voting_form_fields, 1) LOOP
    PERFORM create_voting_form_field(p_voting_form_fields[i]);
  END LOOP;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting form';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ORGANIZER INIT VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_init_voting_session(
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
    WHERE voting_session_id = v_session.id;

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

























-- BEGIN VOTING SESSION PROCEDURE BY ID
--CREATE OR REPLACE FUNCTION begin_voting_session_procedure_by_id (p_id uuid)
--RETURNS void AS $$
--DECLARE
--  v_voting_session_procedure voting_session_procedures;
--  v_voting_session voting_sessions;
--  v_contest_id uuid;
--BEGIN
--  IF EXISTS (
--    SELECT 1 FROM public.voting_sessions
--    WHERE session_status = 'live'
--  ) THEN
--    RAISE EXCEPTION 'A voting session is already live';
--  END IF;
--
--  SELECT *
--  INTO v_voting_session_procedure
--  FROM voting_session_procedures
--  WHERE id = p_id;
--
--  SELECT *
--  INTO v_voting_session
--  FROM voting_sessions
--  WHERE id = v_voting_session_procedure.voting_session_id;
--
--  -- Imposto a live la voting session
--  UPDATE voting_sessions
--  SET
--    session_status = 'live'
--  WHERE id = v_voting_session.id;
--
--  -- Inizializzo i campi di procedure per la sessione
--  UPDATE voting_session_procedures
--  SET
--    current_step = 'initialized'::voting_session_procedure_step
--  WHERE id = p_id;
--END;
--$$ LANGUAGE plpgsql SECURITY definer;

-- START VOTING SESSION PROCEDURE BY ID
--CREATE OR REPLACE FUNCTION organizer_start_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
--DECLARE
--  v_procedure voting_session_procedures;
--  v_session voting_sessions;
--  v_work_timer interval;
--  v_job_name text := 'voting_session_procedure_' || p_id;
--BEGIN
--  SELECT work_timer * INTERVAL '1 seconds'
--  INTO v_work_timer
--  FROM voting_sessions vs
--  JOIN voting_session_procedures pr
--  ON pr.voting_session_id = vs.id
--  WHERE pr.id = p_id;
--
--  UPDATE voting_session_procedures
--  SET
--    current_step              = 'work'::voting_session_procedure_step,
--    current_participant_index = 0,
--    current_step_deadline     = now() + v_work_timer
--  WHERE id = p_id;
--
--  -- Schedule a cron job for this session
--  PERFORM cron.schedule(
--    v_job_name,
--    '1 seconds',
--    format($fmt$ SELECT advance_voting_session_procedure_by_id('%s'); $fmt$,
--      p_id
--    )
--  );
--END;
--$$ LANGUAGE plpgsql SECURITY definer;
--
---- ADVANCE VOTING SESSION PROCEDURE BY ID
--CREATE OR REPLACE FUNCTION organizer_advance_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
--DECLARE
--  v_session voting_sessions;
--  v_procedure voting_session_procedures;
--  v_next_index int;
--  v_next_step text;
--  v_delay interval;
--  v_count int;
--  v_job_name text;
--  v_timers RECORD;
--BEGIN
--  SELECT *
--  INTO v_procedure
--  FROM voting_session_procedures
--  WHERE id = p_id;
--
--  SELECT *
--  INTO v_session
--  FROM voting_sessions
--  WHERE id = v_procedure.voting_session_id;
--
--  RAISE NOTICE 'Step corrente: %', v_procedure.current_step;
--  RAISE NOTICE 'Deadline scaduta? %', (v_procedure.current_step_deadline <= now());
--
--  IF v_session.session_status = 'live' AND v_procedure.current_step_deadline <= now() THEN
--    -- Prendo i timer dalla tabella principale
--    SELECT work_timer, intermission_timer, review_timer
--    INTO v_timers
--    FROM voting_sessions
--    WHERE id = v_procedure.voting_session_id;
--
--    -- Numero di partecipanti
--    SELECT COUNT(*) INTO v_count
--    FROM voting_session_participations p
--    WHERE p.voting_session_id = v_procedure.voting_session_id;
--
--    -- Diversifico per step corrente
--    IF v_procedure.current_step = 'work' THEN
--      -- Work finito → intermission su *stesso* indice
--      v_next_step := 'intermission';
--      v_delay     := v_timers.intermission_timer  * INTERVAL '1 seconds';
--      v_next_index  := v_procedure.current_participant_index;
--
--    ELSIF v_procedure.current_step = 'intermission' THEN
--      -- Intermission finito → se ci sono altri partecipanti, vai a work+1,
--      -- altrimenti entri in review
--      IF (v_procedure.current_participant_index + 1) < v_count THEN
--        v_next_step := 'work';
--        v_delay     := v_timers.work_timer  * INTERVAL '1 seconds';
--        v_next_index  := v_procedure.current_participant_index + 1;
--      ELSE
--        v_next_step := 'review';
--        v_delay     := v_timers.review_timer * INTERVAL '1 seconds';
--        v_next_index  := NULL;
--      END IF;
--
--    ELSIF v_procedure.current_step = 'review' THEN
--      -- Review finita → ended
--      v_next_step := 'ended';
--      v_delay     := NULL;
--      v_next_index  := NULL;
--
--    ELSE
--      -- (non dovrebbe capitare) fallback alla fine
--      v_next_step := 'cancelled';
--      v_delay     := NULL;
--      v_next_index  := NULL;
--    END IF;
--
--    IF v_next_step = 'cancelled' THEN
--      v_job_name := 'voting_session_procedure_' || v_procedure.id;
--      PERFORM cron.unschedule(v_job_name);
--      UPDATE voting_session_procedures
--      SET
--        current_step          = v_next_step::voting_session_procedure_step,
--        current_participant_index = NULL,
--        current_step_deadline = NULL
--      WHERE id = v_procedure.id;
--      UPDATE voting_sessions
--      SET
--        is_ended = false
--      WHERE id = v_procedure.voting_session_id;
--    END IF;
--
--    -- Se passo a END, unschedule + update
--    IF v_next_step = 'ended' THEN
--      v_job_name := 'voting_session_procedure_' || v_procedure.id;
--      PERFORM cron.unschedule(v_job_name);
--      UPDATE voting_session_procedures
--      SET
--        current_step          = v_next_step::voting_session_procedure_step,
--        current_participant_index = NULL,
--        current_step_deadline = NULL
--      WHERE id = v_procedure.id;
--      UPDATE voting_sessions
--      SET
--        session_status = v_next_step::voting_session_status
--      WHERE id = v_procedure.voting_session_id;
--      -- DELETE FROM voting_session_procedures WHERE id = v_procedure.id;
--    ELSE
--      -- Altrimenti aggiorno lo stato
--      UPDATE voting_session_procedures
--      SET
--        current_participant_index = v_next_index,
--        current_step              = v_next_step::voting_session_procedure_step,
--        current_step_deadline     = now() + v_delay
--      WHERE id = v_procedure.id;
--    END IF;
--  END IF;
--END;
--$$ LANGUAGE plpgsql SECURITY definer;
--
---- END VOTING SESSION PROCEDURE BY ID
--CREATE OR REPLACE FUNCTION organizer_end_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
--DECLARE
--  v_job_name text := 'voting_session_procedure_' || p_id;
--BEGIN
--
--  PERFORM cron.unschedule(v_job_name);
--  UPDATE voting_session_procedures
--  SET
--    current_step = 'ended'::voting_session_procedure_step,
--    current_participant_index = NULL,
--    current_step_deadline = NULL
--  WHERE id = p_id;
--
--  UPDATE voting_sessions
--  SET
--    session_status = 'ended'::voting_session_status
--  WHERE id = v_procedure.voting_session_id;
--END;
--$$ LANGUAGE plpgsql SECURITY definer;
--
---- CANCEL VOTING SESSION PROCEDURE BY ID
--CREATE OR REPLACE FUNCTION organizer_cancel_voting_session_procedure_by_id (p_id uuid)
--RETURNS void AS $$
--DECLARE
--  v_job_name text := 'voting_session_procedure_' || p_id;
--  v_job_exists boolean;
--BEGIN
--
--  SELECT EXISTS(
--    SELECT 1
--    FROM cron.job
--    WHERE jobname = v_job_name
--  ) INTO v_job_exists;
--
--  IF v_job_exists THEN
--    PERFORM cron.unschedule(v_job_name);
--  END IF;
--
--  UPDATE voting_session_procedures
--  SET
--    current_step          = 'cancelled'::voting_session_procedure_step,
--    current_participant_index = NULL,
--    current_step_deadline = NULL
--  WHERE id = p_id;
--
--  UPDATE voting_sessions
--  SET
--    session_status = 'cancelled'::voting_session_status
--  WHERE id = (
--    SELECT voting_session_id
--    FROM voting_session_procedures
--    WHERE id = p_id
--  );
--
--END;
--$$ LANGUAGE plpgsql SECURITY definer;
