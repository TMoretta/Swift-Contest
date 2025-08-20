--region GET CREATED CONTESTS
-- Retrieves a list of contests created by the authenticated user.
-- No parameters are needed as it uses auth.uid() to identify the organizer.
CREATE OR REPLACE FUNCTION organizer_get_created_contests()
RETURNS SETOF jsonb
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- This function retrieves all contests created by a specific organizer,
  -- bundling the main details with participant and juror counts.

  -- Security check: Ensure the user has a profile before proceeding.
  -- If not found, the function raises a clear exception.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Organizer profile not found.';
  END IF;

  -- Executes the query and returns the results in the requested format.
   RETURN QUERY
   SELECT
     -- We now build a single JSON object for each row, which matches the `RETURNS SETOF jsonb` signature.
     jsonb_build_object(
       -- 1. The 'contest_bundle' object, constructed as before.
       'contest_bundle', jsonb_build_object(
         'contest', to_jsonb(c),
         'organizer', to_jsonb(p),
         'place', to_jsonb(pl)
       ),

       -- 2. 'participants_number'
       'participants_number', (
         SELECT COUNT(*)::int
         FROM public.participations pa
         WHERE pa.contest_id = c.id
       ),

       -- 3. 'jurors_number'
       'jurors_number', (
         SELECT COUNT(*)::int
         FROM public.jurations ju
         WHERE ju.contest_id = c.id
       )
     )
   FROM
     public.contests AS c
     -- JOIN to get the organizer's profile details.
     JOIN public.profiles AS p ON c.organizer_id = p.id
     -- JOIN to get the contest's place details.
     JOIN public.places AS pl ON c.place_id = pl.id
   WHERE
     c.organizer_id = auth.uid()
   ORDER BY
       c.created_at DESC;
END;
$$;

--region ORGANIZER GET CONTEST DETAILS BUNDLE
-- Retrieves all nested data for a contest's detail page, restricted to the organizer.
CREATE OR REPLACE FUNCTION organizer_get_contest_details(p_contest_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
 result_bundle jsonb;
BEGIN
 -- SECURITY CHECK: Ensure the caller is the organizer of the contest.
 IF NOT EXISTS (SELECT 1 FROM public.contests WHERE id = p_contest_id AND organizer_id = auth.uid()) THEN
   RAISE EXCEPTION 'Access denied or contest not found.';
 END IF;

 -- If the check passes, build the complete JSON response.
 SELECT jsonb_build_object(
   'contest_bundle', (
     SELECT jsonb_build_object(
              'contest', to_jsonb(c),
              'organizer', to_jsonb(p),
              'place', to_jsonb(pl)
            )
     FROM public.contests c
     JOIN public.profiles p ON c.organizer_id = p.id
     JOIN public.places pl ON c.place_id = pl.id
     WHERE c.id = p_contest_id
   ),
   'participations_bundles', (
     SELECT COALESCE(jsonb_agg(
       jsonb_build_object(
         'participation', to_jsonb(pa),
         'participant', to_jsonb(p),
         'work', to_jsonb(w)
       )
     ), '[]'::jsonb)
     FROM public.participations pa
     JOIN public.profiles p ON pa.participant_id = p.id
     LEFT JOIN public.works w ON pa.id = w.participation_id
     WHERE pa.contest_id = p_contest_id
   ),
   'participants_invitations', (
       SELECT COALESCE(jsonb_agg(to_jsonb(pi)), '[]'::jsonb)
       FROM public.participant_invitations pi
       WHERE pi.contest_id = p_contest_id
   ),
   'juries_bundles', (
       SELECT COALESCE(jsonb_agg(
         jsonb_build_object(
           'jury', to_jsonb(j),
           'jurations_bundles', (
             SELECT COALESCE(jsonb_agg(jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))), '[]'::jsonb)
             FROM public.jurations ju
             JOIN public.profiles p_juror ON ju.juror_id = p_juror.id
             WHERE ju.jury_id = j.id
           ),
           'jurors_invitations', (
             SELECT COALESCE(jsonb_agg(to_jsonb(ji)), '[]'::jsonb)
             FROM public.juror_invitations ji
             WHERE ji.jury_id = j.id
           ),
           'voting_form_bundle', (
             SELECT jsonb_build_object(
               'voting_form', to_jsonb(vf),
               'voting_form_fields', (
                 SELECT COALESCE(jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index), '[]'::jsonb)
                 FROM public.voting_form_fields vff
                 WHERE vff.voting_form_id = vf.id
               )
             )
             FROM public.voting_forms vf
             WHERE vf.id = j.voting_form_id
           )
         )
       ), '[]'::jsonb)
       FROM public.juries j
       WHERE j.contest_id = p_contest_id
   ),
   'voting_sessions_bundles', (
       SELECT COALESCE(jsonb_agg(
         jsonb_build_object(
           'voting_session', to_jsonb(vs),
           'place', to_jsonb(pl)
         )
       ), '[]'::jsonb)
       FROM public.voting_sessions vs
       LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
       WHERE vs.contest_id = p_contest_id
   ),
   'contest_rankings', (
     SELECT COALESCE(jsonb_agg(
       jsonb_build_object(
         'id', cr.id,
         'created_at', cr.created_at,
         'contest_id', cr.contest_id,
         'file_path', cr.file_path
       )
     ), '[]'::jsonb)
     FROM public.contest_rankings cr
     WHERE cr.contest_id = p_contest_id
   )
 )
 INTO result_bundle;

 RETURN result_bundle;
END;
$$;
--endregion

----region CREATE CONTEST
---- Crea un 'place' e un 'contest' in una singola transazione atomica.
---- Se una delle due operazioni fallisce, l'intera transazione viene annullata.
--CREATE OR REPLACE FUNCTION organizer_create_contest(p_contest jsonb, p_place jsonb)
--RETURNS contests -- Restituisce l'intera riga del contest creato.
--LANGUAGE plpgsql
--SECURITY DEFINER
--AS $$
--DECLARE
--  v_place_id uuid;
--  new_contest_row contests;
--BEGIN
--  -- 1. Crea il 'place' e recupera il suo ID.
--  INSERT INTO public.places (address, lat, lon)
--  VALUES (
--    p_place->>'address',
--    (p_place->>'lat')::float,
--    (p_place->>'lon')::float
--  )
--  RETURNING id INTO v_place_id;
--
--  -- 2. Crea il 'contest' usando l'ID del luogo e l'ID dell'organizzatore (auth.uid()).
--  INSERT INTO public.contests (
--    id,
--    organizer_id,
--    name,
--    description,
--    date_time,
--    works_submission_start,
--    works_submission_end,
--    place_id,
--    images_urls
--  )
--  VALUES (
--    (p_contest->>'id')::uuid,
--    auth.uid(), -- Associa il contest all'utente autenticato.
--    p_contest->>'name',
--    p_contest->>'description',
--    (p_contest->>'date_time')::timestamptz,
--    (p_contest->>'works_submission_start')::timestamptz,
--    (p_contest->>'works_submission_end')::timestamptz,
--    v_place_id, -- Usa l'ID del luogo creato al passo 1.
--    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_contest->'images_urls'))
--  )
--  RETURNING * INTO new_contest_row;
--
--  RETURN new_contest_row;
--END;
--$$;
--
----region UPDATE CONTEST
---- Aggiorna un 'contest' e il suo 'place' associato in una transazione.
--CREATE OR REPLACE FUNCTION organizer_update_contest(p_contest jsonb, p_place jsonb)
--RETURNS contests
--LANGUAGE plpgsql
--SECURITY DEFINER
--AS $$
--DECLARE
--  updated_contest_row contests;
--BEGIN
--  -- 1. Aggiorna il 'place'.
--  UPDATE public.places
--  SET
--    address = p_place->>'address',
--    lat = (p_place->>'lat')::float,
--    lon = (p_place->>'lon')::float
--  WHERE id = (p_place->>'id')::uuid;
--
--  -- 2. Aggiorna il 'contest', verificando che l'utente sia l'organizzatore.
--  UPDATE public.contests
--  SET
--    name = p_contest->>'name',
--    description = p_contest->>'description',
--    date_time = (p_contest->>'date_time')::timestamptz,
--    works_submission_start = (p_contest->>'works_submission_start')::timestamptz,
--    works_submission_end = (p_contest->>'works_submission_end')::timestamptz,
--    images_urls = (SELECT array_agg(value) FROM jsonb_array_elements_text(p_contest->'images_urls'))
--  WHERE id = (p_contest->>'id')::uuid AND organizer_id = auth.uid()
--  RETURNING * INTO updated_contest_row;
--
--  -- Se la riga non è stata aggiornata (perché l'utente non è l'organizzatore), solleva un errore.
--  IF NOT FOUND THEN
--    RAISE EXCEPTION 'Contest not found or access denied.';
--  END IF;
--
--  RETURN updated_contest_row;
--END;
--$$;

--region CREATE JURY
-- Creates a 'jury' and its associated 'voting_form' in a single transaction.
-- It can accept optional details for the voting form for greater flexibility.
CREATE OR REPLACE FUNCTION organizer_create_jury(
  p_jury jsonb,
  p_voting_form_details jsonb DEFAULT NULL -- Optional details for the voting form
)
RETURNS juries
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_contest_id uuid := (p_jury->>'contest_id')::uuid;
  v_voting_form_id uuid;
  v_jury_name text := p_jury->>'name';
  new_jury_row juries;
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer of the contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest not found or access denied.';
  END IF;

  -- 1. Create a new voting_form.
  --    If custom details are provided, use them. Otherwise, use defaults.
  INSERT INTO public.voting_forms (name, description)
  VALUES (
    COALESCE(p_voting_form_details->>'name', v_jury_name), -- Use custom name or jury name
    COALESCE(p_voting_form_details->>'description', 'Voting form for jury: ' || v_jury_name) -- Use custom description or default
  )
  RETURNING id INTO v_voting_form_id;

  -- 2. Create the new jury, linking it to the form created above.
  INSERT INTO public.juries (contest_id, name, voting_form_id, type)
  VALUES (
    v_contest_id,
    v_jury_name,
    v_voting_form_id,
    (p_jury->>'type')::jury_type
  )
  RETURNING * INTO new_jury_row;

  RETURN new_jury_row;
END;
$$;

--region UPDATE VOTING FORM
-- Updates the fields of a voting form using a "delete-then-insert" strategy.
-- Access is restricted to the organizer of the contest to which the form belongs.
CREATE OR REPLACE FUNCTION organizer_update_voting_form (
  p_voting_form_id uuid, -- ID of the form to update
  p_name varchar, -- New name for the form
  p_description varchar, -- New description for the form
  p_voting_form_fields jsonb -- A JSON array of the new fields
)
RETURNS SETOF voting_form_fields
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this voting form.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_forms vf
    JOIN public.juries j ON vf.id = j.voting_form_id
    JOIN public.contests c ON j.contest_id = c.id
    WHERE vf.id = p_voting_form_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Voting form not found or access denied.';
  END IF;

  -- If the security check passes, proceed with the updates.

  -- Update the form's name and description
  UPDATE public.voting_forms
  SET
    name = p_name,
    description = p_description
  WHERE id = p_voting_form_id;

  -- 1. Delete all existing fields for this form.
  DELETE FROM public.voting_form_fields WHERE voting_form_id = p_voting_form_id;

  -- 2. Insert the new fields from the JSON array.
  RETURN QUERY
  INSERT INTO public.voting_form_fields (
    voting_form_id,
    question,
    order_index,
    type,
    is_required,
    scope,
    slider_min_value,
    slider_max_value
  )
  SELECT
    p_voting_form_id,
    (f->>'question')::varchar,
    (f->>'order_index')::int,
    (f->>'type')::voting_form_field_type,
    (f->>'is_required')::bool,
    (f->>'scope')::voting_form_field_scope,
    (f->>'slider_min_value')::int,
    (f->>'slider_max_value')::int
  FROM jsonb_array_elements(p_voting_form_fields) AS f
  RETURNING *;
END;
$$;
--endregion

--region ORGANIZER START VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_start_voting_session(
  p_voting_session jsonb,
  p_participations_ids uuid[],
  p_exclusions jsonb,
  p_geo_res_place jsonb -- Can be NULL
)
RETURNS voting_sessions -- Returns the entire created voting session row.
LANGUAGE plpgsql
-- Runs with the creator's privileges to allow inserting into 'places' and to snapshot data efficiently.
-- Security is enforced by the initial check on the contest's organizer.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_contest_id uuid := (p_voting_session->>'contest_id')::uuid;
  v_session_id uuid;
  v_geo_res_place_id uuid;
  v_jury_record record;
  v_new_voting_form_id uuid;
  v_session_jury_id uuid;
  v_new_session voting_sessions;
  v_original_form_name text;
  v_original_form_description text;
  v_contest_name text;
  v_session_name text;
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer of the contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest not found or access denied.';
  END IF;

  -- Get contest name and session name for the notification message
  SELECT name INTO v_contest_name FROM public.contests WHERE id = v_contest_id;
  v_session_name := p_voting_session->>'name';

  -- 1. Create the 'Place' for geo-restriction, ONLY if provided.
  IF p_geo_res_place IS NOT NULL THEN
    INSERT INTO public.places (address, lat, lon)
    VALUES (
      p_geo_res_place->>'address',
      (p_geo_res_place->>'lat')::float,
      (p_geo_res_place->>'lon')::float
    )
    RETURNING id INTO v_geo_res_place_id;
  END IF;

  -- 2. Create the main voting session row.
  INSERT INTO public.voting_sessions (
    contest_id, name, is_geo_restricted, session_status,
    geo_res_place_id, geo_res_radius
  ) VALUES (
    v_contest_id,
    p_voting_session->>'name',
    (p_voting_session->>'is_geo_restricted')::bool,
    'live',
    v_geo_res_place_id, -- Will be NULL if not created
    (p_voting_session->>'geo_res_radius')::int
  )
  RETURNING id INTO v_session_id;

  -- 3. Create SNAPSHOTS of the selected PARTICIPANTS.
  INSERT INTO public.voting_session_participants (
    voting_session_id, participation_id,
    participant_full_name, work_name, work_description, work_images_paths,
    order_index
  )
  SELECT
    v_session_id, pa.id,
    pr.full_name, w.name, w.description, w.images_paths,
    u.ord - 1
  FROM unnest(p_participations_ids) WITH ORDINALITY AS u(id, ord) -- Unnest array while preserving order
    JOIN public.participations pa ON pa.id = u.id
    JOIN public.profiles pr ON pa.participant_id = pr.id
    JOIN public.works w ON pa.id = w.participation_id;

  -- 4. Iterate over each JURY in the contest to create snapshots.
  FOR v_jury_record IN
    SELECT * FROM public.juries WHERE contest_id = v_contest_id
  LOOP
    -- 4.a: Get name and description from the original voting form.
    SELECT name, description INTO v_original_form_name, v_original_form_description
    FROM public.voting_forms
    WHERE id = v_jury_record.voting_form_id;

    -- 4.b: Create a NEW voting_form for the snapshot, copying name and description.
    INSERT INTO public.voting_forms (name, description) VALUES (v_original_form_name, v_original_form_description)
    RETURNING id INTO v_new_voting_form_id;

    -- 4.c: Copy fields from the original form to the new one (snapshot of fields).
    INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope)
    SELECT
      v_new_voting_form_id,
      vff.question, vff.order_index, vff.type, vff.slider_min_value, vff.slider_max_value, vff.is_required, vff.scope
    FROM public.voting_form_fields vff
    WHERE vff.voting_form_id = v_jury_record.voting_form_id;

    -- 4.d: Create the jury snapshot.
    INSERT INTO public.voting_session_juries (
      voting_session_id, jury_id, jury_name, jury_type, voting_form_id, jury_token
    ) VALUES (
      v_session_id, v_jury_record.id, v_jury_record.name, v_jury_record.type, v_new_voting_form_id, v_jury_record.token
    )
    RETURNING id INTO v_session_jury_id;

    -- 4.e: Create snapshots of the individual jurors.
    INSERT INTO public.voting_session_jurors (
      voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name
    )
    SELECT
      v_session_id,
      v_session_jury_id,
      ju.id,
      ju.juror_id,
      pr.full_name
    FROM
      public.jurations ju
      JOIN public.profiles pr ON ju.juror_id = pr.id
    WHERE
      ju.jury_id = v_jury_record.id;
  END LOOP;

  -- 5. Create the specific EXCLUSIONS.
  INSERT INTO public.voting_session_exclusions (
    voting_session_id,
    voting_session_juror_id,
    voting_session_participant_id
  )
  SELECT
    v_session_id,
    vsj.id,
    vsp.id
  FROM
    jsonb_to_recordset(p_exclusions) AS x(juration_id uuid, participation_id uuid)
    JOIN public.voting_session_jurors vsj ON vsj.juration_id = x.juration_id AND vsj.voting_session_id = v_session_id
    JOIN public.voting_session_participants vsp ON vsp.participation_id = x.participation_id AND vsp.voting_session_id = v_session_id;

  -- 6. Notify all appointed jurors in the contest that a new session has started.
  INSERT INTO public.messages (account_id, title, body)
  SELECT
    DISTINCT ju.juror_id, -- Use DISTINCT to ensure a juror gets only one message
    'New Voting Session Started',
    'A new voting session "' || v_session_name || '" has started for the contest "' || v_contest_name || '".'
  FROM public.jurations ju
  WHERE ju.contest_id = v_contest_id;

  -- 7. Fetch and return the complete row of the newly created session.
  SELECT * INTO v_new_session FROM public.voting_sessions WHERE id = v_session_id;
  RETURN v_new_session;
END;
$$;
--endregion

--region ORGANIZER END VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_end_voting_session(p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer of the contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Voting session not found or access denied.';
  END IF;

  -- If the check passes, proceed with the update.
  UPDATE public.voting_sessions
  SET
    session_status = 'ended'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    -- This error is unlikely if the check above succeeds, but it's good practice to keep it.
    RAISE EXCEPTION 'Voting session not found.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER CANCEL VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_cancel_voting_session (p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer of the contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Voting session not found or access denied.';
  END IF;

  -- If the check passes, proceed with the update.
  UPDATE public.voting_sessions
  SET
    session_status = 'cancelled'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    -- This error is unlikely if the check above succeeds, but it's good practice to keep it.
    RAISE EXCEPTION 'Voting session not found.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER GET VOTING SESSION PROCEDURE BUNDLE
-- Retrieves all data necessary for conducting a voting session.
-- Access is restricted to the contest organizer.
-- Returns a single JSON object that maps to the Dart 'VotingSessionProcedureBundle' class.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_procedure_bundle(p_voting_session_id uuid)
RETURNS jsonb -- Returns a single JSONB object, not a table.
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SECURITY CHECK: Verify that the calling user is the organizer of the contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Voting session not found or access denied.';
  END IF;

  -- Build the final JSON object using subqueries for each field in the bundle.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle'
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl) -- Will be 'null' if the LEFT JOIN finds no match
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = p_voting_session_id
    ),

    -- 2. 'voting_session_participants'
    'voting_session_participants', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participants vsp
      WHERE vsp.voting_session_id = p_voting_session_id
    ),

    -- 3. 'voting_session_juries_bundles'
    'voting_session_juries_bundles', (
      SELECT COALESCE(
        jsonb_agg(
          -- For each jury in the session, build its bundle
          jsonb_build_object(
            'voting_session_jury', to_jsonb(vsj),
            'voting_session_jurors', (
               SELECT COALESCE(jsonb_agg(to_jsonb(vsju) ORDER BY vsju.created_at), '[]'::jsonb)
               FROM public.voting_session_jurors vsju
               WHERE vsju.voting_session_jury_id = vsj.id
            ),
            'voting_form_bundle', (
                SELECT jsonb_build_object(
                    'voting_form', to_jsonb(vf),
                    'voting_form_fields', COALESCE(
                        (SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
                         FROM public.voting_form_fields vff
                         WHERE vff.voting_form_id = vsj.voting_form_id),
                        '[]'::jsonb
                    )
                )
                FROM public.voting_forms vf
                WHERE vf.id = vsj.voting_form_id
            )
          )
        ),
        '[]'::jsonb
      )
      FROM public.voting_session_juries vsj
      WHERE vsj.voting_session_id = p_voting_session_id
    ),

    -- 4. 'voting_session_exclusions'
    'voting_session_exclusions', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vse)), '[]'::jsonb)
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_id = p_voting_session_id
    )

  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region ORGANIZER GET VOTING SESSION RESULT BUNDLE
-- Retrieves the complete result data for a voting session, restricted to the contest organizer.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_result_bundle(p_voting_session_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this voting session.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Voting session not found or access denied.';
  END IF;

  -- If the check passes, build the final JSON bundle.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle'
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = p_voting_session_id
    ),

    -- 2. 'voting_session_juries_bundles'
    'voting_session_juries_bundles', (
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'voting_session_jury', to_jsonb(vsj),
        'voting_form_bundle', (
            SELECT jsonb_build_object(
              'voting_form', to_jsonb(vf),
              'voting_form_fields', COALESCE((SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index) FROM public.voting_form_fields vff WHERE vff.voting_form_id = vsj.voting_form_id), '[]'::jsonb)
            ) FROM public.voting_forms vf WHERE vf.id = vsj.voting_form_id
        ),
        'voting_session_jurors', COALESCE((SELECT jsonb_agg(to_jsonb(vsjuror) ORDER BY vsjuror.juror_full_name) FROM public.voting_session_jurors vsjuror WHERE vsjuror.voting_session_jury_id = vsj.id), '[]'::jsonb)
      )), '[]'::jsonb)
      FROM public.voting_session_juries vsj
      WHERE vsj.voting_session_id = p_voting_session_id
    )
  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region ORGANIZER GET VOTING SESSION JURY RESULT BUNDLE
-- Retrieves the complete result data for a specific jury within a voting session,
-- restricted to the contest organizer.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_jury_result_bundle(p_voting_session_jury_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_voting_session_id uuid;
  result_bundle jsonb;
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer and get the session ID.
  SELECT vsj.voting_session_id INTO v_voting_session_id
  FROM public.voting_session_juries vsj
  JOIN public.voting_sessions vs ON vsj.voting_session_id = vs.id
  JOIN public.contests c ON vs.contest_id = c.id
  WHERE vsj.id = p_voting_session_jury_id AND c.organizer_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Jury not found or access denied.';
  END IF;

  -- If the check passes, build the final JSON bundle.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle'
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = v_voting_session_id
    ),

    -- 2. 'voting_session_jury_bundle'
    'voting_session_jury_bundle', (
      SELECT jsonb_build_object(
        'voting_session_jury', to_jsonb(vsj),
        'voting_form_bundle', (
          SELECT jsonb_build_object(
            'voting_form', to_jsonb(vf),
            'voting_form_fields', COALESCE(
              (SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
               FROM public.voting_form_fields vff
               WHERE vff.voting_form_id = vsj.voting_form_id),
              '[]'::jsonb
            )
          )
          FROM public.voting_forms vf
          WHERE vf.id = vsj.voting_form_id
        ),
        'voting_session_jurors', COALESCE(
          (SELECT jsonb_agg(to_jsonb(vsjuror) ORDER BY vsjuror.juror_full_name)
           FROM public.voting_session_jurors vsjuror
           WHERE vsjuror.voting_session_jury_id = vsj.id),
          '[]'::jsonb
        )
      )
      FROM public.voting_session_juries vsj
      WHERE vsj.id = p_voting_session_jury_id
    ),

    -- 3. 'voting_session_participants'
    'voting_session_participants', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participants vsp
      WHERE vsp.voting_session_id = v_voting_session_id
    ),

    -- 4. 'voting_session_exclusions' (for this jury only)
    'voting_session_exclusions', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vse)), '[]'::jsonb)
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_juror_id IN (
        SELECT id FROM public.voting_session_jurors WHERE voting_session_jury_id = p_voting_session_jury_id
      )
    ),

    -- 5. 'voting_form_submissions_bundles'
    'voting_form_submissions_bundles', (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'voting_form_submission', to_jsonb(vfs),
          'voting_session_juror', to_jsonb(vsj),
          'voting_form_submission_values_bundles', (
            SELECT COALESCE(jsonb_agg(
              jsonb_build_object(
                'voting_form_submission_value', to_jsonb(vfsv),
                'voting_form_field', to_jsonb(vff),
                'voting_session_participant', to_jsonb(vsp)
              )
            ), '[]'::jsonb)
            FROM public.voting_form_submission_values vfsv
            JOIN public.voting_form_fields vff ON vfsv.voting_form_field_id = vff.id
            LEFT JOIN public.voting_session_participants vsp ON vfsv.voting_session_participant_id = vsp.id
            WHERE vfsv.voting_form_submission_id = vfs.id
          )
        )
      ), '[]'::jsonb)
      FROM public.voting_form_submissions vfs
      JOIN public.voting_session_jurors vsj ON vfs.voting_session_juror_id = vsj.id
      WHERE vsj.voting_session_jury_id = p_voting_session_jury_id
    )

  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region ORGANIZER GET VOTING SESSION JUROR RESULT BUNDLE
-- Retrieves the complete result data for a specific juror within a voting session,
-- restricted to the contest organizer.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_juror_result_bundle(p_voting_session_juror_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_voting_session_id uuid;
  v_voting_session_jury_id uuid;
  v_voting_form_id uuid;
  result_bundle jsonb;
BEGIN
  -- SECURITY CHECK: Verify that the user is the organizer and get necessary IDs.
  SELECT
    vsj2.voting_session_id,
    vsj.voting_session_jury_id,
    vsj2.voting_form_id
  INTO
    v_voting_session_id,
    v_voting_session_jury_id,
    v_voting_form_id
  FROM public.voting_session_jurors vsj
  JOIN public.voting_session_juries vsj2 ON vsj.voting_session_jury_id = vsj2.id
  JOIN public.voting_sessions vs ON vsj2.voting_session_id = vs.id
  JOIN public.contests c ON vs.contest_id = c.id
  WHERE vsj.id = p_voting_session_juror_id AND c.organizer_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juror not found or access denied.';
  END IF;

  -- If the check passes, build the final JSON bundle.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle' (session details)
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = v_voting_session_id
    ),

    -- 2. 'voting_session_jury' (the jury this juror belongs to)
    'voting_session_jury', (
        SELECT to_jsonb(vsj)
        FROM public.voting_session_juries vsj
        WHERE vsj.id = v_voting_session_jury_id
    ),

    -- 3. 'voting_form_bundle' (the form this juror used)
    'voting_form_bundle', (
      SELECT jsonb_build_object(
        'voting_form', to_jsonb(vf),
        'voting_form_fields', COALESCE(
          (SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
           FROM public.voting_form_fields vff
           WHERE vff.voting_form_id = v_voting_form_id),
          '[]'::jsonb
        )
      )
      FROM public.voting_forms vf
      WHERE vf.id = v_voting_form_id
    ),

    -- 4. 'voting_session_participants' (all participants in the session)
    'voting_session_participants', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participants vsp
      WHERE vsp.voting_session_id = v_voting_session_id
    ),

    -- 5. 'excluded_voting_session_participants_ids' (for this specific juror)
    'excluded_voting_session_participants_ids', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vse.voting_session_participant_id)), '[]'::jsonb)
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_juror_id = p_voting_session_juror_id
    ),

    -- 6. 'voting_form_submission_bundle' (the submission from this specific juror)
    'voting_form_submission_bundle', (
      SELECT jsonb_build_object(
        'voting_form_submission', to_jsonb(vfs),
        'voting_session_juror', to_jsonb(vsj),
        'voting_form_submission_values_bundles', (
          -- OPTIMIZED: Replaced correlated subqueries with JOINs for better performance.
          SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
              'voting_form_submission_value', to_jsonb(vfsv),
              'voting_form_field', to_jsonb(vff),
              'voting_session_participant', to_jsonb(vsp)
            ) ORDER BY vff.order_index
          ), '[]'::jsonb)
          FROM public.voting_form_submission_values vfsv
          JOIN public.voting_form_fields vff ON vfsv.voting_form_field_id = vff.id
          LEFT JOIN public.voting_session_participants vsp ON vfsv.voting_session_participant_id = vsp.id
          WHERE vfsv.voting_form_submission_id = vfs.id
        )
      )
      FROM public.voting_form_submissions vfs
      WHERE vfs.voting_session_juror_id = p_voting_session_juror_id
    )

  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region ORGANIZER GET PARTICIPATION BUNDLE
 -- Retrieves the details of a single participation (participation, participant, and work).
 -- Access is restricted to the contest organizer.
 CREATE OR REPLACE FUNCTION organizer_get_participation_bundle(p_participation_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- Runs with the permissions of the calling user.
 -- Added search_path for security and consistency.
 SECURITY DEFINER SET search_path = public, extensions
 AS $$
 DECLARE
   result_bundle jsonb;
 BEGIN
   -- SECURITY CHECK: Verify that the current user is the organizer of the contest
   -- this participation belongs to.
   IF NOT EXISTS (
     SELECT 1
     FROM public.participations pa
     JOIN public.contests c ON pa.contest_id = c.id
     WHERE
       pa.id = p_participation_id
       AND c.organizer_id = auth.uid()
   ) THEN
     RAISE EXCEPTION 'Participation not found or access denied.';
   END IF;

   -- If the security check passes, build the bundle.
   SELECT jsonb_build_object(
     'participation', to_jsonb(pa),
     'participant', to_jsonb(p),
     'work', to_jsonb(w)
   )
   INTO result_bundle
   FROM public.participations pa
   JOIN public.profiles p ON pa.participant_id = p.id
   LEFT JOIN public.works w ON pa.id = w.participation_id
   WHERE pa.id = p_participation_id;

   RETURN result_bundle;
 END;
 $$;
 --endregion

 --region ORGANIZER GET JURY BUNDLE
 -- Retrieves the complete details of a single jury.
 -- Access is restricted to the contest organizer.
 CREATE OR REPLACE FUNCTION organizer_get_jury_bundle(p_jury_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- Runs with the permissions of the calling user.
 -- Added search_path for security and consistency.
 SECURITY DEFINER SET search_path = public, extensions
 AS $$
 DECLARE
   result_bundle jsonb;
 BEGIN
   -- SECURITY CHECK: Verify that the current user is the organizer of the contest.
   IF NOT EXISTS (
     SELECT 1
     FROM public.juries j
     JOIN public.contests c ON j.contest_id = c.id
     WHERE j.id = p_jury_id AND c.organizer_id = auth.uid()
   ) THEN
     RAISE EXCEPTION 'Jury not found or access denied.';
   END IF;

   -- If the security check passes, build the complete jury bundle.
   SELECT
     jsonb_build_object(
       'jury', to_jsonb(j),
       'jurations_bundles', COALESCE(
         (
           SELECT jsonb_agg(
             jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))
           )
           FROM public.jurations ju
           JOIN public.profiles p_juror ON ju.juror_id = p_juror.id
           WHERE ju.jury_id = j.id
         ),
         '[]'::jsonb
       ),
       'jurors_invitations', COALESCE(
         (
           SELECT jsonb_agg(to_jsonb(ji))
           FROM public.juror_invitations ji
           WHERE ji.jury_id = j.id
         ),
         '[]'::jsonb
       ),
       'voting_form_bundle', (
         SELECT jsonb_build_object(
           'voting_form', to_jsonb(vf),
           'voting_form_fields', COALESCE(
             (
               SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
               FROM public.voting_form_fields vff
               WHERE vff.voting_form_id = vf.id
             ),
             '[]'::jsonb
           )
         )
         FROM public.voting_forms vf
         WHERE vf.id = j.voting_form_id
       )
     )
   INTO result_bundle
   FROM public.juries j
   WHERE j.id = p_jury_id;

   RETURN result_bundle;
 END;
 $$;
 --endregion

--region ORGANIZER GET VOTING FORM BUNDLE
 -- Retrieves a voting form and all its associated fields.
 -- Access is restricted to the contest organizer.
 CREATE OR REPLACE FUNCTION organizer_get_voting_form_bundle(p_voting_form_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- Runs with the permissions of the calling user.
 -- Added search_path for security and consistency.
 SECURITY DEFINER SET search_path = public, extensions
 AS $$
 DECLARE
   result_bundle jsonb;
 BEGIN
   -- SECURITY CHECK: Verify that the current user is the organizer of the contest
   -- associated with this voting form.
   IF NOT EXISTS (
     SELECT 1
     FROM public.voting_forms vf
     JOIN public.juries j ON vf.id = j.voting_form_id
     JOIN public.contests c ON j.contest_id = c.id
     WHERE vf.id = p_voting_form_id AND c.organizer_id = auth.uid()
   ) THEN
     RAISE EXCEPTION 'Voting form not found or access denied.';
   END IF;

   -- If the security check passes, build the bundle.
   SELECT
     jsonb_build_object(
       'voting_form', to_jsonb(vf),
       'voting_form_fields', COALESCE(
         (
           SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
           FROM public.voting_form_fields vff
           WHERE vff.voting_form_id = vf.id
         ),
         '[]'::jsonb
       )
     )
   INTO result_bundle
   FROM public.voting_forms vf
   WHERE vf.id = p_voting_form_id;

   RETURN result_bundle;
 END;
 $$;
 --endregion

--region ORGANIZER REGENERATE JURY TOKEN
-- Regenerates the token for a specific jury.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_regenerate_jury_token(p_jury_id uuid)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_new_token text; -- Variable to hold the new token
BEGIN
  -- SECURITY CHECK & UPDATE: The WHERE clause implicitly verifies ownership
  -- by joining through the contests table and checking the organizer_id.
  -- A new unique token is generated and set in the same statement.
  UPDATE public.juries j
  SET token = public.gen_unique_token('juries', 'token', 14)
  FROM public.contests c
  WHERE j.id = p_jury_id
    AND j.contest_id = c.id
    AND c.organizer_id = auth.uid()
  RETURNING j.token INTO v_new_token; -- Capture the newly generated token

  -- If no row was updated, it means the jury was not found or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Jury not found or access denied.';
  END IF;

  RETURN v_new_token; -- Return the new token to the client
END;
$$;
--endregion

--region ORGANIZER DELETE PARTICIPANT INVITATION
-- Deletes a participant invitation.
-- Access is restricted to the organizer of the contest to which the invitation belongs.
CREATE OR REPLACE FUNCTION organizer_delete_participant_invitation(p_participant_invitation_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this invitation before deleting.
  IF NOT EXISTS (
    SELECT 1
    FROM public.participant_invitations pi
    JOIN public.contests c ON pi.contest_id = c.id
    WHERE pi.id = p_participant_invitation_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Invitation not found or access denied.';
  END IF;

  -- If the check passes, delete the invitation.
  DELETE FROM public.participant_invitations
  WHERE id = p_participant_invitation_id;
END;
$$;
--endregion

--region ORGANIZER DELETE JUROR INVITATION
-- Deletes a juror invitation.
-- Access is restricted to the organizer of the contest to which the invitation belongs.
CREATE OR REPLACE FUNCTION organizer_delete_juror_invitation(p_juror_invitation_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this invitation before deleting.
  IF NOT EXISTS (
    SELECT 1
    FROM public.juror_invitations ji
    JOIN public.contests c ON ji.contest_id = c.id
    WHERE ji.id = p_juror_invitation_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Invitation not found or access denied.';
  END IF;

  -- If the check passes, delete the invitation.
  DELETE FROM public.juror_invitations
  WHERE id = p_juror_invitation_id;
END;
$$;

--region ORGANIZER DELETE JURY
-- Deletes a jury. Access is restricted to the organizer of the contest.
-- The associated voting form is deleted automatically via ON DELETE CASCADE.
CREATE OR REPLACE FUNCTION organizer_delete_jury(p_jury_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_jury_name TEXT;
  v_contest_name TEXT;
BEGIN
  -- 1. SECURITY CHECK & FETCH DATA: Verify ownership and get names for the notification.
  SELECT j.name, c.name
  INTO v_jury_name, v_contest_name
  FROM public.juries j
  JOIN public.contests c ON j.contest_id = c.id
  WHERE j.id = p_jury_id AND c.organizer_id = auth.uid();

  -- If no record is found, the jury doesn't exist or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Jury not found or access denied.';
  END IF;

  -- 2. NOTIFY JURORS: Insert a message for each juror who is about to be removed.
  -- This must be done BEFORE deleting the jury, as the deletion will cascade to 'jurations'.
  INSERT INTO public.messages (account_id, title, body)
  SELECT
    ju.juror_id,
    'Jury Dissolved',
    'The jury "' || v_jury_name || '" for the contest "' || v_contest_name || '" has been dissolved. Thank you for your participation.'
  FROM
    public.jurations ju
  WHERE
    ju.jury_id = p_jury_id;

  -- 3. DELETE JURY: If the check passes, delete the jury.
  -- The ON DELETE CASCADE constraint will automatically remove associated jurations, invitations, etc.
 DELETE FROM public.juries WHERE id = p_jury_id;
END;
$$;
--endregion

--region ORGANIZER REMOVE JUROR
-- Removes a juror from a contest by deleting their juration record.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_remove_juror(p_juration_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_juror_id uuid;
  v_contest_name text;
  v_jury_name text;
BEGIN
  -- 1. SECURITY CHECK & FETCH DATA: Verify ownership and get data for the notification.
  SELECT
    ju.juror_id,
    c.name,
    j.name
  INTO
    v_juror_id,
    v_contest_name,
    v_jury_name
  FROM public.jurations ju
  JOIN public.contests c ON ju.contest_id = c.id
  JOIN public.juries j ON ju.jury_id = j.id
  WHERE ju.id = p_juration_id AND c.organizer_id = auth.uid();

  -- If no record is found, the juration doesn't exist or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juror not found or access denied.';
  END IF;

  -- 2. NOTIFY JUROR: Insert a message for the juror who is about to be removed.
  INSERT INTO public.messages (account_id, title, body)
  VALUES (
    v_juror_id,
    'Removed from Jury',
    'You have been removed from the jury "' || v_jury_name || '" for the contest "' || v_contest_name || '".'
  );

  -- 3. DELETE JURATION: If the check passes, delete the juration.
 DELETE FROM public.jurations
 WHERE id = p_juration_id;
END;
$$;
--endregion

--region ORGANIZER REMOVE PARTICIPANT
-- Removes a participant from a contest by deleting their participation record.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_remove_participant(p_participation_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_participant_id uuid;
  v_contest_name text;
BEGIN
  -- 1. SECURITY CHECK & FETCH DATA: Verify ownership and get data for the notification.
  SELECT
    pa.participant_id,
    c.name
  INTO
    v_participant_id,
    v_contest_name
  FROM public.participations pa
  JOIN public.contests c ON pa.contest_id = c.id
  WHERE pa.id = p_participation_id AND c.organizer_id = auth.uid();

  -- If no record is found, the participation doesn't exist or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Participation not found or access denied.';
  END IF;

  -- 2. NOTIFY PARTICIPANT: Insert a message for the participant who is about to be removed.
  INSERT INTO public.messages (account_id, title, body)
  VALUES (
    v_participant_id,
    'Removed from Contest',
    'You have been removed from the contest "' || v_contest_name || '".'
  );

  -- 3. DELETE PARTICIPATION: If the check passes, delete the participation.
 DELETE FROM public.participations
 WHERE id = p_participation_id;
END;
$$;
--endregion

--region ORGANIZER UPDATE JURY NAME
-- Updates the name of a jury.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_update_jury_name(
 p_jury_id uuid,
 p_name text
)
RETURNS juries -- Returns the entire updated jury row
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
 updated_jury_row juries;
BEGIN
 -- SECURITY CHECK: The WHERE clause implicitly verifies ownership by joining
 -- through the contests table and checking the organizer_id.
 UPDATE public.juries j
 SET name = p_name
 FROM public.contests c
 WHERE j.id = p_jury_id
   AND j.contest_id = c.id
   AND c.organizer_id = auth.uid()
 RETURNING j.* INTO updated_jury_row;

 -- If no row was updated, it means the jury was not found or the user is not the organizer.
 IF NOT FOUND THEN
   RAISE EXCEPTION 'Jury not found or access denied.';
 END IF;

 RETURN updated_jury_row;
END;
$$;
--endregion

--region ORGANIZER UPDATE VOTING SESSION NAME
-- Updates the name of a voting session.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_update_voting_session_name(
  p_voting_session_id uuid,
  p_name text
)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- SECURITY CHECK: The WHERE clause implicitly verifies ownership by joining
  -- through the contests table and checking the organizer_id.
  UPDATE public.voting_sessions vs
  SET name = p_name
  FROM public.contests c
  WHERE vs.id = p_voting_session_id
    AND vs.contest_id = c.id
    AND c.organizer_id = auth.uid();

  -- If no row was updated, it means the session was not found or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Voting session not found or access denied.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER DELETE CONTEST
-- Deletes a contest and all its related data via CASCADE.
-- Access is restricted to the organizer of the contest.
CREATE OR REPLACE FUNCTION organizer_delete_contest(p_contest_id uuid)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_contest_name TEXT;
BEGIN
  -- 1. SECURITY CHECK & FETCH DATA: Verify ownership and get the contest name for notifications.
  SELECT name
  INTO v_contest_name
  FROM public.contests
  WHERE id = p_contest_id AND organizer_id = auth.uid();

  -- If no record is found, the contest doesn't exist or the user is not the organizer.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Contest not found or access denied.';
  END IF;

  -- 2. NOTIFY PARTICIPANTS: Insert a message for each participant.
  -- This must be done BEFORE deleting the contest, as the deletion will cascade to 'participations'.
  INSERT INTO public.messages (account_id, title, body)
  SELECT
    pa.participant_id,
    'Contest Cancelled',
    'The contest "' || v_contest_name || '" you were participating in has been cancelled by the organizer.'
  FROM
    public.participations pa
  WHERE
    pa.contest_id = p_contest_id;

  -- 3. NOTIFY JURORS: Insert a message for each juror.
  -- Use DISTINCT to avoid duplicate messages if a juror is in multiple juries.
  INSERT INTO public.messages (account_id, title, body)
  SELECT
    DISTINCT ju.juror_id,
    'Contest Cancelled',
    'The contest "' || v_contest_name || '" for which you were a juror has been cancelled by the organizer.'
  FROM
    public.jurations ju
  WHERE
    ju.contest_id = p_contest_id;

  -- 4. DELETE CONTEST: Now, delete the contest. The ON DELETE CASCADE will handle related data.
  DELETE FROM public.contests WHERE id = p_contest_id;
END;
$$;
--endregion
