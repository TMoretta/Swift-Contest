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

       -- 2. The 'participations' array.
       --    The subquery is correlated to the contest ID (c.id).
       --    COALESCE ensures an empty array '[]' is returned instead of NULL.
       'participations', COALESCE(
         (
           SELECT jsonb_agg(to_jsonb(pa))
           FROM public.participations AS pa
           WHERE pa.contest_id = c.id
         ),
         '[]'::jsonb
       ),

       -- 3. The 'jurations' array.
       'jurations', COALESCE(
         (
           SELECT jsonb_agg(to_jsonb(ju))
           FROM public.jurations AS ju
           WHERE ju.contest_id = c.id
         ),
         '[]'::jsonb
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
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
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