--region GET CREATED CONTESTS
-- Recupera una lista di contest creati dall'utente autenticato.
-- Non richiede parametri perché usa auth.uid() per identificare l'organizzatore.
CREATE OR REPLACE FUNCTION organizer_get_created_contests()
RETURNS SETOF jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER -- Eseguita con i permessi dell'utente chiamante.
AS $$
BEGIN
  -- Questa funzione recupera tutti i contest creati da un organizzatore specifico,
  -- raggruppando i dettagli principali e le liste di partecipazioni e giurie.

  -- È buona norma verificare che l'organizzatore esista prima di procedere.
  -- Se non viene trovato, la funzione solleva un'eccezione chiara.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Organizer profile not found or access denied.';
  END IF;

  -- Esegue la query e restituisce i risultati nel formato richiesto.
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
     -- JOIN per ottenere i dettagli del profilo dell'organizzatore.
     JOIN public.profiles AS p ON c.organizer_id = p.id
     -- JOIN per ottenere i dettagli del luogo del contest.
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
SECURITY INVOKER
AS $$
DECLARE
 result_bundle jsonb;
BEGIN
 -- Step 1: Security Check - Ensure the caller is the organizer
 IF NOT EXISTS (SELECT 1 FROM public.contests WHERE id = p_contest_id AND organizer_id = auth.uid()) THEN
   RAISE EXCEPTION 'Access denied or contest not found.';
 END IF;

 -- Step 2: Build the JSON response - Organizer gets all data
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

--region CREATE CONTEST
-- Crea un 'place' e un 'contest' in una singola transazione atomica.
-- Se una delle due operazioni fallisce, l'intera transazione viene annullata.
CREATE OR REPLACE FUNCTION organizer_create_contest(p_contest jsonb, p_place jsonb)
RETURNS contests -- Restituisce l'intera riga del contest creato.
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_place_id uuid;
  new_contest_row contests;
BEGIN
  -- 1. Crea il 'place' e recupera il suo ID.
  INSERT INTO public.places (address, lat, lon)
  VALUES (
    p_place->>'address',
    (p_place->>'lat')::float,
    (p_place->>'lon')::float
  )
  RETURNING id INTO v_place_id;

  -- 2. Crea il 'contest' usando l'ID del luogo e l'ID dell'organizzatore (auth.uid()).
  INSERT INTO public.contests (
    id,
    organizer_id,
    organizer_full_name,
    name,
    description,
    date_time,
    works_submission_start,
    works_submission_end,
    place_id,
    images_urls
  )
  VALUES (
    (p_contest->>'id')::uuid,
    auth.uid(), -- Associa il contest all'utente autenticato.
    p_contest->>'organizer_full_name',
    p_contest->>'name',
    p_contest->>'description',
    (p_contest->>'date_time')::timestamptz,
    (p_contest->>'works_submission_start')::timestamptz,
    (p_contest->>'works_submission_end')::timestamptz,
    v_place_id, -- Usa l'ID del luogo creato al passo 1.
    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_contest->'images_urls'))
  )
  RETURNING * INTO new_contest_row;

  RETURN new_contest_row;
END;
$$;

--region UPDATE CONTEST
-- Aggiorna un 'contest' e il suo 'place' associato in una transazione.
CREATE OR REPLACE FUNCTION organizer_update_contest(p_contest jsonb, p_place jsonb)
RETURNS contests
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  updated_contest_row contests;
BEGIN
  -- 1. Aggiorna il 'place'.
  UPDATE public.places
  SET
    address = p_place->>'address',
    lat = (p_place->>'lat')::float,
    lon = (p_place->>'lon')::float
  WHERE id = (p_place->>'id')::uuid;

  -- 2. Aggiorna il 'contest', verificando che l'utente sia l'organizzatore.
  UPDATE public.contests
  SET
    organizer_full_name = p_contest->>'organizer_full_name',
    name = p_contest->>'name',
    description = p_contest->>'description',
    date_time = (p_contest->>'date_time')::timestamptz,
    works_submission_start = (p_contest->>'works_submission_start')::timestamptz,
    works_submission_end = (p_contest->>'works_submission_end')::timestamptz,
    images_urls = (SELECT array_agg(value) FROM jsonb_array_elements_text(p_contest->'images_urls'))
  WHERE id = (p_contest->>'id')::uuid AND organizer_id = auth.uid()
  RETURNING * INTO updated_contest_row;

  -- Se la riga non è stata aggiornata (perché l'utente non è l'organizzatore), solleva un errore.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Contest not found or access denied.';
  END IF;

  RETURN updated_contest_row;
END;
$$;

--region CREATE JURY
-- Creates a 'jury' and its associated 'voting_form' in a single transaction.
-- It can accept optional details for the voting form for greater flexibility.
CREATE OR REPLACE FUNCTION organizer_create_jury(
  p_jury jsonb,
  p_voting_form_details jsonb DEFAULT NULL -- Optional details for the voting form
)
RETURNS juries
LANGUAGE plpgsql
SECURITY INVOKER
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
SECURITY INVOKER
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
  p_geo_res_place jsonb -- Può essere NULL
)
RETURNS voting_sessions -- Restituisce l'intera riga della sessione di voto creata.
LANGUAGE plpgsql
SECURITY INVOKER
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
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest not found or access denied.';
  END IF;

  -- 1. Crea il 'Place' per la geo-restrizione, SOLO SE necessario.
  IF p_geo_res_place IS NOT NULL THEN
    INSERT INTO public.places (address, lat, lon)
    VALUES (
      p_geo_res_place->>'address',
      (p_geo_res_place->>'lat')::float,
      (p_geo_res_place->>'lon')::float
    )
    RETURNING id INTO v_geo_res_place_id;
  END IF;

  -- 2. Crea la riga principale della sessione di voto.
  INSERT INTO public.voting_sessions (
    contest_id, name, is_geo_restricted, session_status,
    geo_res_place_id, geo_res_radius
  ) VALUES (
    v_contest_id,
    p_voting_session->>'name',
    (p_voting_session->>'is_geo_restricted')::bool,
    'live',
    v_geo_res_place_id, -- Sarà NULL se non è stato creato
    (p_voting_session->>'geo_res_radius')::int
  )
  RETURNING id INTO v_session_id;

  -- 3. Crea gli SNAPSHOT dei PARTECIPANTI selezionati.
  INSERT INTO public.voting_session_participants (
    voting_session_id, participation_id,
    participant_full_name, work_name, work_description, work_images_urls,
    order_index
  )
  SELECT
    v_session_id, pa.id,
    pr.full_name, w.name, w.description, w.images_urls,
    u.ord - 1
  FROM
    unnest(p_participations_ids) WITH ORDINALITY AS u(id, ord) -- Espande l'array mantenendo l'ordine
    JOIN public.participations pa ON pa.id = u.id
    JOIN public.profiles pr ON pa.participant_id = pr.id
    JOIN public.works w ON pa.id = w.participation_id;

  -- 4. Itera su ogni GIURIA del contest per creare gli snapshot.
  FOR v_jury_record IN
    SELECT * FROM public.juries WHERE contest_id = v_contest_id
  LOOP
    -- 4.a: Ottieni nome e descrizione dal modulo di voto originale.
    SELECT name, description INTO v_original_form_name, v_original_form_description
    FROM public.voting_forms
    WHERE id = v_jury_record.voting_form_id;

    -- 4.b: Crea un NUOVO voting_form per lo snapshot, copiando nome e descrizione.
    INSERT INTO public.voting_forms (name, description) VALUES (v_original_form_name, v_original_form_description)
    RETURNING id INTO v_new_voting_form_id;

    -- 4.c: Copia i campi dal form originale al nuovo form (snapshot dei campi).
    -- AGGIORNATO: Nomi delle colonne 'question', 'slider_*' e 'scope' allineati al nuovo schema.
    INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope)
    SELECT
      v_new_voting_form_id,
      vff.question, vff.order_index, vff.type, vff.slider_min_value, vff.slider_max_value, vff.is_required, vff.scope
    FROM public.voting_form_fields vff
    WHERE vff.voting_form_id = v_jury_record.voting_form_id;

    -- 4.d: Crea lo snapshot della giuria.
    -- AGGIORNATO: Aggiunto 'jury_type' e corretto 'jury_token'.
    INSERT INTO public.voting_session_juries (
      voting_session_id, jury_id, jury_name, jury_type, voting_form_id, jury_token
    ) VALUES (
      v_session_id, v_jury_record.id, v_jury_record.name, v_jury_record.type, v_new_voting_form_id, v_jury_record.token
    )
    RETURNING id INTO v_session_jury_id;

    -- 4.e: Crea gli snapshot dei singoli giurati.
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

  -- 5. Crea le ESCLUSIONI specifiche.
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

  -- 6. Recupera e restituisce la riga completa della sessione appena creata.
  SELECT * INTO v_new_session FROM public.voting_sessions WHERE id = v_session_id;
  RETURN v_new_session;
END;
$$;
--endregion

--region ORGANIZER END VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_end_voting_session(p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER -- Modificato per maggiore sicurezza
AS $$
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Sessione di voto non trovata o accesso non autorizzato.';
  END IF;

  -- Prosegui con l'aggiornamento solo se il controllo è superato.
  UPDATE public.voting_sessions
  SET
    session_status = 'ended'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    -- Questo errore è improbabile se il controllo sopra ha successo, ma è una buona pratica mantenerlo.
    RAISE EXCEPTION 'Sessione di voto non trovata.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER CANCEL VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_cancel_voting_session (p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER -- Modificato per maggiore sicurezza
AS $$
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Sessione di voto non trovata o accesso non autorizzato.';
  END IF;

  -- Prosegui con l'aggiornamento solo se il controllo è superato.
  UPDATE public.voting_sessions
  SET
    session_status = 'cancelled'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    -- Questo errore è improbabile se il controllo sopra ha successo, ma è una buona pratica mantenerlo.
    RAISE EXCEPTION 'Sessione di voto non trovata.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER GET VOTING SESSION PROCEDURE BUNDLE
-- Recupera tutti i dati necessari per la conduzione di una sessione di voto.
-- Accessibile sia dall'organizzatore che dai giurati partecipanti.
-- Restituisce un singolo oggetto JSON che mappa la classe Dart 'VotingSessionProcedureBundle'.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_procedure_bundle(p_voting_session_id uuid)
RETURNS jsonb -- Restituisce un singolo oggetto JSONB, non una tabella.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SICUREZZA: Verifica che l'utente che chiama la funzione sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_sessions vs
    JOIN public.contests c ON vs.contest_id = c.id
    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Sessione di voto non trovata o accesso non autorizzato.';
  END IF;

  -- Costruisce l'oggetto JSON finale usando subquery per ogni campo del bundle.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle'
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl) -- Sarà 'null' se il LEFT JOIN non trova corrispondenze
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
          -- Per ogni giuria della sessione, costruisce il suo bundle
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
-- Retrieves the complete result data for a voting session, intended for the contest organizer.
-- This function bundles the session details, all its juries, their forms, and their jurors.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_result_bundle(p_voting_session_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  v_contest_organizer_id uuid;
  result_bundle jsonb;
BEGIN
  -- STEP 1: Security Check
  -- Find the organizer_id of the contest this voting session belongs to.
  SELECT c.organizer_id
  INTO v_contest_organizer_id
  FROM public.voting_sessions vs
  JOIN public.contests c ON vs.contest_id = c.id
  WHERE vs.id = p_voting_session_id;

  -- If no session is found, or if the caller is not the organizer, raise an exception.
  IF NOT FOUND OR v_contest_organizer_id <> auth.uid() THEN
    RAISE EXCEPTION 'Access denied: You are not the organizer of this contest or the session does not exist.';
  END IF;

  -- STEP 2: Build the final JSON bundle
  SELECT jsonb_build_object(
    -- Part 1: 'voting_session_bundle'
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = p_voting_session_id
    ),

    -- Part 2: 'voting_session_juries_bundles'
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
-- Retrieves the complete result data for a specific jury within a voting session.
-- This is intended for the contest organizer to view detailed results for one jury.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_jury_result_bundle(p_voting_session_jury_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  v_voting_session_id uuid;
  v_contest_organizer_id uuid;
  result_bundle jsonb;
BEGIN
  -- STEP 1: Security Check & Get Session ID
  -- Find the organizer_id and session_id associated with the given jury.
  SELECT vsj.voting_session_id, c.organizer_id
  INTO v_voting_session_id, v_contest_organizer_id
  FROM public.voting_session_juries vsj
  JOIN public.voting_sessions vs ON vsj.voting_session_id = vs.id
  JOIN public.contests c ON vs.contest_id = c.id
  WHERE vsj.id = p_voting_session_jury_id;

  -- If no jury is found, or if the caller is not the organizer, raise an exception.
  IF NOT FOUND OR v_contest_organizer_id <> auth.uid() THEN
    RAISE EXCEPTION 'Access denied: You are not the organizer of this contest or the jury does not exist.';
  END IF;

  -- STEP 2: Build the final JSON bundle
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
          'voting_session_juror', (
            SELECT to_jsonb(vsj) FROM public.voting_session_jurors vsj WHERE vsj.id = vfs.voting_session_juror_id
          ),
          'voting_form_submission_values_bundles', (
            SELECT COALESCE(jsonb_agg(
              jsonb_build_object(
                'voting_form_submission_value', to_jsonb(vfsv),
                'voting_form_field', (
                  SELECT to_jsonb(vff) FROM public.voting_form_fields vff WHERE vff.id = vfsv.voting_form_field_id
                ),
                'voting_session_participant', (
                  SELECT to_jsonb(vsp) FROM public.voting_session_participants vsp WHERE vsp.id = vfsv.voting_session_participant_id
                )
              )
            ), '[]'::jsonb)
            FROM public.voting_form_submission_values vfsv
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
-- Retrieves the complete result data for a specific juror within a voting session.
-- This is intended for the contest organizer to view detailed results for one juror.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_juror_result_bundle(p_voting_session_juror_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  v_voting_session_id uuid;
  v_voting_session_jury_id uuid;
  v_contest_organizer_id uuid;
  v_voting_form_id uuid;
  result_bundle jsonb;
BEGIN
  -- STEP 1: Security Check & Get Key IDs
  -- Find the organizer_id and other necessary IDs associated with the given juror.
  SELECT
      vsj2.voting_session_id,
      vsj.voting_session_jury_id,
      c.organizer_id,
      vsj2.voting_form_id
  INTO
      v_voting_session_id,
      v_voting_session_jury_id,
      v_contest_organizer_id,
      v_voting_form_id
  FROM public.voting_session_jurors vsj
  JOIN public.voting_session_juries vsj2 ON vsj.voting_session_jury_id = vsj2.id
  JOIN public.voting_sessions vs ON vsj2.voting_session_id = vs.id
  JOIN public.contests c ON vs.contest_id = c.id
  WHERE vsj.id = p_voting_session_juror_id;

  -- If no juror is found, or if the caller is not the organizer, raise an exception.
  IF NOT FOUND OR v_contest_organizer_id <> auth.uid() THEN
    RAISE EXCEPTION 'Access denied: You are not the organizer of this contest or the juror does not exist.';
  END IF;

  -- STEP 2: Build the final JSON bundle
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

    -- 2. 'voting_session_jury'
    'voting_session_jury', (
        SELECT to_jsonb(vsj)
        FROM public.voting_session_juries vsj
        WHERE vsj.id = v_voting_session_jury_id
    ),

    -- 3. 'voting_form_bundle'
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

    -- 4. 'voting_session_participants'
    'voting_session_participants', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participants vsp
      WHERE vsp.voting_session_id = v_voting_session_id
    ),

    -- 5. 'excluded_voting_session_participants_ids' (for this juror only)
    'excluded_voting_session_participants_ids', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vse.voting_session_participant_id)), '[]'::jsonb)
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_juror_id = p_voting_session_juror_id
    ),

    -- 6. 'voting_form_submission_bundle'
    'voting_form_submission_bundle', (
      SELECT jsonb_build_object(
        'voting_form_submission', to_jsonb(vfs),
        'voting_session_juror', (
          SELECT to_jsonb(vsj) FROM public.voting_session_jurors vsj WHERE vsj.id = vfs.voting_session_juror_id
        ),
        'voting_form_submission_values_bundles', (
          SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
              'voting_form_submission_value', to_jsonb(vfsv),
              'voting_form_field', (
                SELECT to_jsonb(vff) FROM public.voting_form_fields vff WHERE vff.id = vfsv.voting_form_field_id
              ),
              'voting_session_participant', (
                SELECT to_jsonb(vsp) FROM public.voting_session_participants vsp WHERE vsp.id = vfsv.voting_session_participant_id
              )
            ) ORDER BY (SELECT vff.order_index FROM public.voting_form_fields vff WHERE vff.id = vfsv.voting_form_field_id)
          ), '[]'::jsonb)
          FROM public.voting_form_submission_values vfsv
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
 SECURITY INVOKER
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
 SECURITY INVOKER
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
 SECURITY INVOKER
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

--region ORGANIZER DELETE PARTICIPANT INVITATION
-- Deletes a participant invitation.
-- Access is restricted to the organizer of the contest to which the invitation belongs.
CREATE OR REPLACE FUNCTION organizer_delete_participant_invitation(p_invitation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this invitation before deleting.
  IF NOT EXISTS (
    SELECT 1
    FROM public.participant_invitations pi
    JOIN public.contests c ON pi.contest_id = c.id
    WHERE pi.id = p_invitation_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Invitation not found or access denied.';
  END IF;

  -- If the check passes, delete the invitation.
  DELETE FROM public.participant_invitations
  WHERE id = p_invitation_id;
END;
$$;
--endregion

--region ORGANIZER DELETE JUROR INVITATION
-- Deletes a juror invitation.
-- Access is restricted to the organizer of the contest to which the invitation belongs.
CREATE OR REPLACE FUNCTION organizer_delete_juror_invitation(p_invitation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
  -- SECURITY CHECK: Verify that the current user is the organizer of the contest
  -- associated with this invitation before deleting.
  IF NOT EXISTS (
    SELECT 1
    FROM public.juror_invitations ji
    JOIN public.contests c ON ji.contest_id = c.id
    WHERE ji.id = p_invitation_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Invitation not found or access denied.';
  END IF;

  -- If the check passes, delete the invitation.
  DELETE FROM public.juror_invitations
  WHERE id = p_invitation_id;
END;
$$;

--region ORGANIZER DELETE JURY
-- Deletes a jury. Access is restricted to the organizer of the contest.
-- The associated voting form is deleted automatically via ON DELETE CASCADE.
CREATE OR REPLACE FUNCTION organizer_delete_jury(p_jury_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
BEGIN
 -- SECURITY CHECK: Verify that the current user is the organizer of the contest
 -- to which this jury belongs before allowing deletion.
 IF NOT EXISTS (
   SELECT 1
   FROM public.juries j
   JOIN public.contests c ON j.contest_id = c.id
   WHERE j.id = p_jury_id AND c.organizer_id = auth.uid()
 ) THEN
   RAISE EXCEPTION 'Jury not found or access denied.';
 END IF;

 -- If the check passes, delete the jury.
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
SECURITY INVOKER
AS $$
BEGIN
 -- SECURITY CHECK: Verify that the current user is the organizer of the contest
 -- associated with this juration before deleting.
 IF NOT EXISTS (
   SELECT 1
   FROM public.jurations ju
   JOIN public.contests c ON ju.contest_id = c.id
   WHERE ju.id = p_juration_id AND c.organizer_id = auth.uid()
 ) THEN
   RAISE EXCEPTION 'Juration not found or access denied.';
 END IF;

 -- If the check passes, delete the juration.
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
SECURITY INVOKER
AS $$
BEGIN
 -- SECURITY CHECK: Verify that the current user is the organizer of the contest
 -- associated with this participation before deleting.
 IF NOT EXISTS (
   SELECT 1
   FROM public.participations pa
   JOIN public.contests c ON pa.contest_id = c.id
   WHERE pa.id = p_participation_id AND c.organizer_id = auth.uid()
 ) THEN
   RAISE EXCEPTION 'Participation not found or access denied.';
 END IF;

 -- If the check passes, delete the participation.
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
SECURITY INVOKER
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
SECURITY INVOKER
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
SECURITY INVOKER
AS $$
BEGIN
 -- The WHERE clause acts as a security check, ensuring that only the
 -- organizer of the contest can delete it.
 DELETE FROM public.contests
 WHERE id = p_contest_id AND organizer_id = auth.uid();

 -- If no row was deleted, it means the contest was not found or the user
 -- did not have permission.
 IF NOT FOUND THEN
   RAISE EXCEPTION 'Contest not found or access denied.';
 END IF;
END;
$$;
--endregion
