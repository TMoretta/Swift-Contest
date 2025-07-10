--region organizer get created contests
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
DECLARE
  v_profile profiles;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT * INTO v_profile
  FROM profiles
  WHERE id = p_organizer_id AND deleted_at is null;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Organizer not found';
  END IF;

  IF (
    v_profile.user_id <> auth.uid()
  ) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the organizer of this contest';
  END IF;

  RETURN QUERY
    SELECT
      to_jsonb(cont) AS contest,
      to_jsonb(org) AS organizer,
      to_jsonb(pla) AS place,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(par) ORDER BY par.created_at DESC)
        FROM participations par
        WHERE par.contest_id = cont.id
      ), '[]'::jsonb) AS participations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur) ORDER BY jur.created_at DESC)
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
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER GET CONTEST DETAILS
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

--region organizer create contest
CREATE OR REPLACE FUNCTION organizer_create_contest (
  p_contest contests,
  p_place places
)
RETURNS contests AS $$
DECLARE
  v_profile profiles;
  v_place places;
  v_voting_form voting_forms;
  v_contest_status contest_status;
  v_contest contests;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT * INTO v_profile
  FROM profiles
  WHERE id = p_contest.organizer_id AND deleted_at is null;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Organizer not found';
  END IF;

  IF (
    v_profile.user_id <> auth.uid()
  ) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the organizer of this contest';
  END IF;

  INSERT INTO places (
    address,
    lat,
    lon
  )
  VALUES (
    p_place.address,
    p_place.lat,
    p_place.lon
  )
  RETURNING * INTO v_place;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while creating the contest';
  END IF;

  INSERT INTO voting_forms (
    id,
    created_at
  )
  VALUES (
    default,
    default
  )
  RETURNING * INTO v_voting_form;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while creating the contest';
  END IF;

  v_contest_status := CASE
    WHEN now() < p_contest.works_submission_start THEN
      'preparationPhase'
    WHEN now() BETWEEN p_contest.works_submission_start AND p_contest.works_submission_end THEN
      'participationPhase'
    ELSE
      'votingPhase'
  END;

  INSERT INTO contests (
    organizer_id,
    name,
    description,
    date_time,
    works_submission_start,
    works_submission_end,
    place_id,
    contest_status,
    images_urls,
    voting_form_id
  )
  VALUES (
    p_contest.organizer_id,
    p_contest.name,
    p_contest.description,
    p_contest.date_time,
    p_contest.works_submission_start,
    p_contest.works_submission_end,
    v_place.id,
    v_contest_status,
    p_contest.images_urls,
    v_voting_form.id
  )
  RETURNING * INTO v_contest;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while creating the contest';
  END IF;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region organizer edit contest
CREATE OR REPLACE FUNCTION organizer_edit_contest (
  p_contest_id uuid,
  p_name varchar,
  p_description varchar,
  p_place places,
  p_date_time timestamptz,
  p_works_submission_start timestamptz,
  p_works_submission_end timestamptz,
  p_images_urls text[]
)
RETURNS contests AS $$
DECLARE
  v_organizer_id uuid;
  v_profile profiles;
  v_contest_status contest_status;
  v_contest contests;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT organizer_id INTO v_organizer_id
  FROM contests WHERE id = p_contest_id;

  SELECT * INTO v_profile
  FROM profiles
  WHERE id = v_organizer_id AND deleted_at is null;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Organizer not found';
  END IF;

  IF (
    v_profile.user_id <> auth.uid()
  ) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the organizer of this contest';
  END IF;

  IF EXISTS (
    SELECT 1 FROM contests
    WHERE id = p_contest_id AND deleted_at is not null
  ) THEN
    RAISE EXCEPTION 'Operation not allowed, the contest has been deleted';
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id AND deleted_at is null;

  v_contest_status := CASE
    WHEN now() < v_contest.works_submission_start THEN
      'preparationPhase'
    WHEN now() BETWEEN v_contest.works_submission_start AND v_contest.works_submission_end THEN
      'participationPhase'
    ELSE
      'votingPhase'
  END;

  UPDATE contests
  SET
    name = p_name,
    description = p_description,
    date_time = p_date_time,
    contest_status = v_contest_status,
    works_submission_start = p_works_submission_start,
    works_submission_end = p_works_submission_end,
    images_urls = p_images_urls
  WHERE id = p_contest_id
  RETURNING * INTO v_contest;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating contest';
  END IF;

  RETURN v_contest;

--EXCEPTION
--  WHEN SQLSTATE 'P0001' THEN
--    RAISE;
--  WHEN OTHERS THEN
--    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region organizer update voting form fields
CREATE OR REPLACE FUNCTION organizer_update_voting_form_fields (
  p_voting_form_id uuid,
  p_voting_form_fields voting_form_fields[]
)
RETURNS SETOF voting_form_fields AS $$
DECLARE
  v_organizer_id uuid;
  v_profile profiles;
  v_field voting_form_fields;
BEGIN

  IF (auth.uid() = null) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not authenticated';
  END IF;

  SELECT organizer_id INTO v_organizer_id
  FROM contests
  WHERE voting_form_id = p_voting_form_id;

  SELECT * INTO v_profile
  FROM profiles
  WHERE id = v_organizer_id AND deleted_at is null;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Organizer not found';
  END IF;

  IF (
    v_profile.user_id <> auth.uid()
  ) THEN
    RAISE EXCEPTION 'Operation not allowed, you are not the organizer of this contest';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM voting_forms
    WHERE id = p_voting_form_id
  ) THEN
    RAISE EXCEPTION 'Voting form not found';
  END IF;

  DELETE FROM voting_form_fields
  WHERE voting_form_id = p_voting_form_id;

  IF p_voting_form_fields IS NOT NULL THEN
    FOREACH v_field IN ARRAY p_voting_form_fields LOOP
      INSERT INTO voting_form_fields (
        voting_form_id,
        name,
        order_index,
        min_value,
        max_value
      )
      VALUES (
        p_voting_form_id,
        v_field.name,
        v_field.order_index,
        v_field.min_value,
        v_field.max_value
      )
      RETURNING * INTO v_field;

      IF NOT FOUND THEN
        RAISE EXCEPTION 'An error occurred while updating the voting form fields';
      END IF;

      -- 4) Emetto quel record al client
      RETURN NEXT v_field;
    END LOOP;
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexpected error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER SET CONTEST STATUS AS ACTIVE
CREATE OR REPLACE FUNCTION organizer_set_contest_status_as_active (
  p_contest_id uuid
)
RETURNS contests AS $$
DECLARE
  v_contest_status contest_status;
  v_contest contests;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM contests
    WHERE id = p_contest_id
  ) THEN
    RAISE EXCEPTION 'Contest not found';
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  IF (v_contest.deleted_at is not null) THEN
    RAISE EXCEPTION 'Can not execute, the contest has been deleted';
  END IF;

  v_contest_status := CASE
    WHEN now() < v_contest.works_submission_start THEN
      'preparationPhase'
    WHEN now() BETWEEN v_contest.works_submission_start AND v_contest.works_submission_end THEN
      'participationPhase'
    ELSE
      'votingPhase'
  END;

  UPDATE contests
  SET contest_status = v_contest_status
  WHERE id = p_contest_id
  RETURNING * INTO v_contest;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating the contest status';
  END IF;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER SET CONTEST STATUS AS TERMINATED
CREATE OR REPLACE FUNCTION organizer_set_contest_status_as_terminated (
  p_contest_id uuid
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM contests
    WHERE id = p_contest_id
  ) THEN
    RAISE EXCEPTION 'Contest not found';
  END IF;

  IF EXISTS (
    SELECT 1 FROM contests
    WHERE id = p_contest_id AND deleted_at is not null
  ) THEN
    RAISE EXCEPTION 'Can not execute, the contest has been deleted';
  END IF;

  UPDATE contests
  SET contest_status = 'terminated'
  WHERE id = p_contest_id
  RETURNING * INTO v_contest;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating the contest status';
  END IF;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER INIT VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_init_voting_session (
  p_voting_form_fields voting_form_fields[],
  p_geores_place places,
  p_voting_session voting_sessions,
  p_voting_session_participations voting_session_participations[],
  p_voting_session_jurations voting_session_jurations[],
  p_voting_session_exclusions voting_session_exclusions[]
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_form voting_forms;
  v_geores_place places;
  v_voting_session voting_sessions;
  v_voting_form_field voting_form_fields;
  v_voting_session_participation voting_session_participations;
  v_voting_session_juration voting_session_jurations;
  v_voting_session_exclusion voting_session_exclusions;
BEGIN
  IF EXISTS (
    SELECT 1
    FROM voting_sessions
    WHERE contest_id = p_voting_session.contest_id AND session_status <> 'ended' AND session_status <> 'cancelled'
  ) THEN
    RAISE EXCEPTION 'A voting session is already in progress for this contest';
  END IF;

  INSERT INTO voting_forms (
    id,
    created_at
  )
  VALUES (
    default,
    default
  )
  RETURNING * INTO v_voting_form;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while initializing the voting session';
  END IF;

  FOR i IN 1..array_length(p_voting_form_fields, 1) LOOP
    v_voting_form_field := p_voting_form_fields[i];
    INSERT INTO voting_form_fields (
      voting_form_id,
      name,
      order_index,
      min_value,
      max_value
    )
    VALUES (
      v_voting_form.id,
      v_voting_form_field.name,
      v_voting_form_field.order_index,
      v_voting_form_field.min_value,
      v_voting_form_field.max_value
    );

    IF NOT FOUND THEN
      RAISE EXCEPTION 'An error occurred while initializing the voting session';
    END IF;
  END LOOP;

  IF p_geores_place IS NOT NULL THEN
    INSERT INTO places (
      address,
      lat,
      lon
    )
    VALUES (
      p_geores_place.address,
      p_geores_place.lat,
      p_geores_place.lon
    )
    RETURNING * INTO v_geores_place;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'An error occurred while initializing the voting session';
    END IF;
  END IF;

  INSERT INTO voting_sessions (
    name,
    contest_id,
    are_simple_jurors_allowed,
    voting_form_id,
    work_timer,
    intermission_timer,
    review_timer,
    session_status,
    is_geo_restricted,
    geo_res_place_id,
    geo_res_radius
  )
  VALUES (
    p_voting_session.name,
    p_voting_session.contest_id,
    p_voting_session.are_simple_jurors_allowed,
    v_voting_form.id,
    p_voting_session.work_timer,
    p_voting_session.intermission_timer,
    p_voting_session.review_timer,
    p_voting_session.session_status,
    p_voting_session.is_geo_restricted,
    v_geores_place.id,
    p_voting_session.geo_res_radius
  )
  RETURNING * INTO v_voting_session;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while initializing the voting session';
  END IF;

  FOR i IN 1..array_length(p_voting_session_participations, 1) LOOP
    v_voting_session_participation := p_voting_session_participations[i];
    INSERT INTO voting_session_participations (
      id,
      voting_session_id,
      participation_id,
      order_index,
      is_excluded
    )
    VALUES (
      v_voting_session_participation.id,
      v_voting_session.id,
      v_voting_session_participation.participation_id,
      v_voting_session_participation.order_index,
      v_voting_session_participation.is_excluded
    );

    IF NOT FOUND THEN
      RAISE EXCEPTION 'An error occurred while initializing the voting session';
    END IF;
  END LOOP;

  FOR i IN 1..array_length(p_voting_session_jurations, 1) LOOP
    v_voting_session_juration := p_voting_session_jurations[i];
    INSERT INTO voting_session_jurations (
      id,
      voting_session_id,
      juration_id,
      is_excluded
    )
    VALUES (
      v_voting_session_juration.id,
      v_voting_session.id,
      v_voting_session_juration.juration_id,
      v_voting_session_juration.is_excluded
    );

    IF NOT FOUND THEN
      RAISE EXCEPTION 'An error occurred while initializing the voting session';
    END IF;
  END LOOP;

  IF array_length(p_voting_session_exclusions, 1) IS NOT NULL THEN
    FOR i IN 1..array_length(p_voting_session_exclusions, 1) LOOP
      v_voting_session_exclusion := p_voting_session_exclusions[i];
      INSERT INTO voting_session_exclusions (
        voting_session_id,
        voting_session_juration_id,
        voting_session_participation_id
      )
      VALUES (
        v_voting_session.id,
        v_voting_session_exclusion.voting_session_juration_id,
        v_voting_session_exclusion.voting_session_participation_id
      );

      IF NOT FOUND THEN
        RAISE EXCEPTION 'An error occurred while initializing the voting session';
      END IF;
    END LOOP;
  END IF;


  IF array_length(p_voting_session_jurations, 1) IS NOT NULL THEN
    FOR i IN 1..array_length(p_voting_session_jurations, 1) LOOP
      v_voting_session_juration := p_voting_session_jurations[i];
      IF (v_voting_session_juration.is_excluded = false) THEN
        INSERT INTO messages (
          profile_id,
          title,
          body
        )
        VALUES (
          (SELECT juror_id FROM jurations WHERE id = v_voting_session_juration.juration_id),
          'Voting session started',
          'A new voting session has started for a contest you are judging'
        );
      END IF;
    END LOOP;
  END IF;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER START VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_start_voting_session (
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_work_timer interval;
  v_job_name text := 'voting_session_' || p_voting_session_id;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id
  ) THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id AND session_status <> 'ended' AND session_status <> 'cancelled'
  ) THEN
    RAISE EXCEPTION 'Voting session already ended or cancelled';
  END IF;

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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while starting the voting session';
  END IF;

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
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER ADVANCE VOTING SESSION
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

    -- Se passo a end o cancelled, unschedule + update
    IF v_next_status = 'cancelled' OR v_next_status = 'ended' THEN
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

--region ORGANIZER END VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_end_voting_session(
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_' || p_voting_session_id;
  v_job_exists boolean;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id
  ) THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while ending the voting session';
  END IF;


EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER CANCEL VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_cancel_voting_session (
  p_voting_session_id uuid
)
RETURNS void AS $$
DECLARE
  v_job_name text := 'voting_session_' || p_voting_session_id;
  v_job_exists boolean;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id
  ) THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while cancelling the voting session';
  END IF;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER DELETE INVITATION
CREATE OR REPLACE FUNCTION organizer_delete_invitation (
  p_invitation_id uuid
)
RETURNS invitations AS $$
DECLARE
  v_invitation invitations;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM invitations
    WHERE id = p_invitation_id
  ) THEN
    RAISE EXCEPTION 'Invitation not found';
  END IF;


  DELETE FROM invitations
  WHERE id = p_invitation_id
  RETURNING * INTO v_invitation;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting invitations';
  END IF;

  RETURN v_invitation;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER UPDATE VOTING SESSION NAME
CREATE OR REPLACE FUNCTION organizer_update_voting_session_name (
  p_voting_session_id uuid,
  p_name varchar
)
RETURNS voting_sessions AS $$
DECLARE
  v_voting_session voting_sessions;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM voting_sessions
    WHERE id = p_voting_session_id
  ) THEN
    RAISE EXCEPTION 'Voting session not found';
  END IF;

  UPDATE voting_sessions
  SET name = p_name
  WHERE id = p_voting_session_id
  RETURNING * INTO v_voting_session;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while updating the voting session';
  END IF;

  RETURN v_voting_session;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

--region ORGANIZER REMOVE PARTICIPANT
CREATE OR REPLACE FUNCTION organizer_remove_participant (
  p_participation_id uuid
)
RETURNS void as $$
DECLARE
  v_participation participations;
  v_contest contests;
  v_organizer profiles;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM participations
    WHERE id = p_participation_id
  ) THEN
    RAISE EXCEPTION 'Participant not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM participations
    WHERE id = p_participation_id AND participant_status = 'joined'
  ) THEN
    RAISE EXCEPTION 'Participant is not a member of the contest';
  END IF;

  SELECT * INTO v_participation
  FROM participations
  WHERE id = p_participation_id;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = v_participation.contest_id;

  SELECT * INTO v_organizer
  FROM profiles
  WHERE id = v_contest.organizer_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (
    v_participation.participant_id,
    'Out from contest',
    format(
      'You have been expelled from "%s" by "%s"',
      v_contest.name,
      v_organizer.full_name
    )
  );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while removing the participant';
  END IF;

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
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER REMOVE JUROR
CREATE OR REPLACE FUNCTION organizer_remove_juror (
  p_juration_id uuid
)
RETURNS void as $$
DECLARE
  v_juration jurations;
  v_contest contests;
  v_organizer profiles;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM jurations
    WHERE id = p_juration_id
  ) THEN
    RAISE EXCEPTION 'Juror not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM jurations
    WHERE id = p_juration_id AND juror_status = 'joined'
  ) THEN
    RAISE EXCEPTION 'Juror is not a member of the contest';
  END IF;

  SELECT * INTO v_juration
  FROM jurations
  WHERE id = p_juration_id;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = v_juration.contest_id;

  SELECT * INTO v_organizer
  FROM profiles
  WHERE id = v_contest.organizer_id;

  INSERT INTO messages (profile_id, title, body)
  VALUES (
    v_juration.juror_id,
    'Out from contest',
    format(
      'You have been expelled from "%s" by "%s"',
      v_contest.name,
      v_organizer.full_name
    )
  );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while removing the juror';
  END IF;

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
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER DELETE CONTEST
CREATE OR REPLACE FUNCTION organizer_delete_contest (
  p_contest_id uuid
)
RETURNS contests AS $$
DECLARE
  v_contest contests;
  v_organizer profiles;
  v_participation participations;
  v_juration jurations;
  v_message_title text;
  v_message_body text;
BEGIN

  IF NOT EXISTS (
    SELECT 1 FROM contests
    WHERE id = p_contest_id
  ) THEN
    RAISE EXCEPTION 'Contest not found';
  END IF;

  SELECT * INTO v_contest
  FROM contests
  WHERE id = p_contest_id;

  SELECT * INTO v_organizer
  FROM profiles
  WHERE id = v_contest.organizer_id;

  v_message_title := 'Deleted contest';
  v_message_body  := format(
      '"%s" has been deleted by "%s"',
      v_contest.name,
      v_organizer.full_name
    );

  -- Invio messaggi a tutti i partecipanti
  FOR v_participation IN
    SELECT *
    FROM participations
    WHERE contest_id = p_contest_id AND participant_status = 'joined'
  LOOP
    INSERT INTO messages (profile_id, title, body)
    VALUES (
      v_participation.participant_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  -- Invio messaggi a tutti i giurati
  FOR v_juration IN
    SELECT *
    FROM jurations
    WHERE contest_id = p_contest_id AND juror_status = 'joined'
  LOOP
    INSERT INTO messages (profile_id, title, body)
    VALUES (
      v_juration.juror_id,
      v_message_title,
      v_message_body
    );
  END LOOP;

  UPDATE contests
  SET
    contest_status = 'deleted',
    deleted_at = now()
  WHERE id = p_contest_id;

  DELETE FROM invitations
  WHERE contest_id = p_contest_id;

  RETURN v_contest;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ORGANIZER GET PARTICIPATION BUNDLE
CREATE OR REPLACE FUNCTION organizer_get_participation_bundle (
  p_participation_id uuid
)
RETURNS TABLE (
  participation jsonb,
  participant jsonb,
  work jsonb
) AS $$
BEGIN

  RETURN QUERY
    SELECT
      to_jsonb(p) AS participation,
      to_jsonb(pr) AS participant,
      to_jsonb(w) AS work
    FROM participations p
    JOIN profiles pr ON pr.id = p.participant_id
    LEFT JOIN works w ON w.participation_id = p.id
    WHERE p.id = p_participation_id;

END;
$$ LANGUAGE plpgsql SECURITY definer;
















