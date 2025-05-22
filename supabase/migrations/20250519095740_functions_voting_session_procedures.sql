-- BEGIN VOTING SESSION PROCEDURE BY ID
CREATE OR REPLACE FUNCTION public.begin_voting_session_procedure_by_id (p_id uuid) returns void AS $$
DECLARE
  v_voting_session_procedure public.voting_session_procedures;
  v_voting_session public.voting_sessions;
  v_contest_id uuid;
BEGIN
  SELECT *
  INTO v_voting_session_procedure
  FROM public.voting_session_procedures
  WHERE id = p_id;

  SELECT *
  INTO v_voting_session
  FROM public.voting_sessions
  WHERE id = v_voting_session_procedure.voting_session_id;

  SELECT contest_id
  INTO v_contest_id
  FROM public.voting_sessions
  WHERE id = v_voting_session.id;

  -- Termino altre eventuali procedure zombie per la stessa sessione
  UPDATE public.voting_session_procedures
  SET
    is_live = FALSE
  WHERE id <> p_id AND voting_session_id <> v_voting_session.id AND v_voting_session.contest_id = v_contest_id;

  -- Inizializzo i campi di procedure per la sessione
  UPDATE public.voting_session_procedures
  SET
    is_live = TRUE,
    current_step = 'preparation'::voting_session_procedure_step
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- START VOTING SESSION PROCEDURE BY ID
CREATE OR REPLACE FUNCTION public.start_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
DECLARE
  v_procedure public.voting_session_procedures;
  v_session public.voting_sessions;
  v_work_timer interval;
  v_job_name text := 'voting_session_procedure_' || p_id;
BEGIN
  SELECT work_timer * INTERVAL '1 seconds'
  INTO v_work_timer
  FROM public.voting_sessions vs
  JOIN public.voting_session_procedures pr
  ON pr.voting_session_id = vs.id
  WHERE pr.id = p_id;

  UPDATE public.voting_session_procedures
  SET
    is_live                   = TRUE,
    current_step              = 'work'::voting_session_procedure_step,
    current_participant_index = 0,
    current_step_deadline     = now() + v_work_timer
  WHERE id = p_id;

  -- Schedule a cron job for this session
  PERFORM cron.schedule(
    v_job_name,
    '1 seconds',
    format($fmt$ SELECT public.advance_voting_session_procedure_by_id('%s'); $fmt$,
      p_id
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- ADVANCE VOTING SESSION PROCEDURE BY ID
CREATE OR REPLACE FUNCTION public.advance_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
DECLARE
  v_procedure public.voting_session_procedures;
  v_next_index int;
  v_next_step text;
  v_delay interval;
  v_count int;
  v_job_name text;
  v_timers RECORD;
BEGIN
  SELECT *
  INTO v_procedure
  FROM public.voting_session_procedures
  WHERE id = p_id;

  RAISE NOTICE 'Step corrente: %', v_procedure.current_step;
  RAISE NOTICE 'Deadline scaduta? %', (v_procedure.current_step_deadline <= now());

  IF v_procedure.is_live is true AND v_procedure.current_step_deadline <= now() THEN
    -- Prendo i timer dalla tabella principale
    SELECT work_timer, intermission_timer, review_timer
    INTO v_timers
    FROM public.voting_sessions
    WHERE id = v_procedure.voting_session_id;

    -- Numero di partecipanti
    SELECT COUNT(*) INTO v_count
    FROM public.voting_session_participants p
    WHERE p.voting_session_id = v_procedure.voting_session_id;

    -- Diversifico per step corrente
    IF v_procedure.current_step = 'work' THEN
      -- Work finito → intermission su *stesso* indice
      v_next_step := 'intermission';
      v_delay     := v_timers.intermission_timer  * INTERVAL '1 seconds';
      v_next_index  := v_procedure.current_participant_index;

    ELSIF v_procedure.current_step = 'intermission' THEN
      -- Intermission finito → se ci sono altri partecipanti, vai a work+1,
      -- altrimenti entri in review
      IF (v_procedure.current_participant_index + 1) < v_count THEN
        v_next_step := 'work';
        v_delay     := v_timers.work_timer  * INTERVAL '1 seconds';
        v_next_index  := v_procedure.current_participant_index + 1;
      ELSE
        v_next_step := 'review';
        v_delay     := v_timers.review_timer * INTERVAL '1 seconds';
        v_next_index  := NULL;
      END IF;

    ELSIF v_procedure.current_step = 'review' THEN
      -- Review finita → end
      v_next_step := 'end';
      v_delay     := NULL;
      v_next_index  := NULL;

    ELSE
      -- (non dovrebbe capitare) fallback alla fine
      v_next_step := 'cancelled';
      v_delay     := NULL;
      v_next_index  := NULL;
    END IF;

    IF v_next_step = 'cancelled' THEN
      v_job_name := 'voting_session_procedure_' || v_procedure.id;
      PERFORM cron.unschedule(v_job_name);
      UPDATE public.voting_session_procedures
      SET
        is_live               = FALSE,
        current_step          = v_next_step::voting_session_procedure_step,
        current_participant_index = NULL,
        current_step_deadline = NULL
      WHERE id = v_procedure.id;
      UPDATE public.voting_sessions
      SET
        is_ended = false
      WHERE id = v_procedure.voting_session_id;
    END IF;

    -- Se passo a END, unschedule + update
    IF v_next_step = 'end' THEN
      v_job_name := 'voting_session_procedure_' || v_procedure.id;
      PERFORM cron.unschedule(v_job_name);
      UPDATE public.voting_session_procedures
      SET
        is_live               = FALSE,
        current_step          = v_next_step::voting_session_procedure_step,
        current_participant_index = NULL,
        current_step_deadline = NULL
      WHERE id = v_procedure.id;
      UPDATE public.voting_sessions
      SET
        is_ended = true
      WHERE id = v_procedure.voting_session_id;
      -- DELETE FROM public.voting_session_procedures WHERE id = v_procedure.id;
    ELSE
      -- Altrimenti aggiorno lo stato
      UPDATE public.voting_session_procedures
      SET
        is_live                   = TRUE,
        current_participant_index = v_next_index,
        current_step              = v_next_step::voting_session_procedure_step,
        current_step_deadline     = now() + v_delay
      WHERE id = v_procedure.id;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- END VOTING SESSION PROCEDURE BY ID
CREATE OR REPLACE FUNCTION public.end_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_procedure_' || p_id;
BEGIN

  PERFORM cron.unschedule(v_job_name);
  UPDATE public.voting_session_procedures
  SET
    is_live               = FALSE,
    current_step          = 'end'::voting_session_procedure_step,
    current_participant_index = NULL,
    current_step_deadline = NULL
  WHERE id = p_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;

-- CANCEL VOTING SESSION PROCEDURE BY ID
CREATE OR REPLACE FUNCTION public.cancel_voting_session_procedure_by_id (p_id uuid) RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_procedure_' || p_id;
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

  UPDATE public.voting_session_procedures
  SET
    is_live               = FALSE,
    current_step          = 'cancelled'::voting_session_procedure_step,
    current_participant_index = NULL,
    current_step_deadline = NULL
  WHERE id = p_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;