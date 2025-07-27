-- Questo file contiene tutte le funzioni RPC per le operazioni dell'organizzatore.
-- Tutte le funzioni sono definite con SECURITY INVOKER, il che significa che
-- vengono eseguite con i permessi dell'utente che le chiama.
-- Questo rende fondamentale avere delle policy di Row Level Security (RLS) ben definite,
-- in quanto saranno le RLS a garantire la sicurezza dei dati.

--region GET CREATED CONTESTS
-- Recupera una lista di contest creati dall'utente autenticato.
-- Non richiede parametri perché usa auth.uid() per identificare l'organizzatore.
CREATE OR REPLACE FUNCTION get_created_contests()
RETURNS TABLE (
  contest_bundle jsonb,
  participations jsonb,
  jurations jsonb
)
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
    RAISE EXCEPTION 'Organizzatore con ID % non trovato.', auth.uid();
  END IF;

  -- Esegue la query e restituisce i risultati nel formato richiesto.
  RETURN QUERY
  SELECT
    -- 1. Costruisce l'oggetto JSON 'contest_bundle'.
    --    Utilizza jsonb_build_object per creare la struttura nidificata
    --    e to_jsonb per convertire le intere righe delle tabelle in oggetti JSON.
    jsonb_build_object(
      'contest', to_jsonb(c),
      'organizer', to_jsonb(p),
      'place', to_jsonb(pl)
    ) AS contest_bundle,

    -- 2. Aggrega tutte le partecipazioni in un array JSONB.
    --    La subquery è correlata all'ID del contest (c.id).
    --    COALESCE garantisce che venga restituito un array vuoto '[]' invece di NULL
    --    se non ci sono partecipazioni.
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(pa))
        FROM public.participations AS pa
        WHERE pa.contest_id = c.id
      ),
      '[]'::jsonb
    ) AS participations,

    -- 3. Aggrega tutte le giurie in un array JSONB.
    --    Funziona in modo analogo alle partecipazioni.
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(ju))
        FROM public.jurations AS ju
        WHERE ju.contest_id = c.id
      ),
      '[]'::jsonb
    ) AS jurations
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


--region GET CONTEST DETAILS
-- Recupera i dettagli completi di un singolo contest.
-- Esegue un controllo per assicurarsi che l'utente sia l'organizzatore.
CREATE OR REPLACE FUNCTION get_contest_details(p_contest_id uuid)
RETURNS TABLE (
  contest_bundle jsonb,
  participations_bundles jsonb,
  participants_invitations jsonb,
  juries_bundles jsonb,
  voting_sessions jsonb
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest richiesto.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = p_contest_id
  ) THEN
    RAISE EXCEPTION 'Contest non trovato';
  END IF;

  RETURN QUERY
  SELECT
    -- 1. contest_bundle
    (
      SELECT jsonb_build_object('contest', to_jsonb(c), 'organizer', to_jsonb(p), 'place', to_jsonb(pl))
      FROM public.contests c
      JOIN public.profiles p ON c.organizer_id = p.id
      JOIN public.places pl ON c.place_id = pl.id
      WHERE c.id = p_contest_id
    ),
    -- 2. participations_bundles
    COALESCE((
      SELECT jsonb_agg(jsonb_build_object('participation', to_jsonb(pa), 'participant', to_jsonb(p), 'work', to_jsonb(w)))
      FROM public.participations pa
      JOIN public.profiles p ON pa.participant_id = p.id
      LEFT JOIN public.works w ON w.participation_id = pa.id
      WHERE pa.contest_id = p_contest_id
    ), '[]'::jsonb),
    -- 3. participants_invitations
    COALESCE((SELECT jsonb_agg(to_jsonb(pi)) FROM public.participant_invitations pi WHERE pi.contest_id = p_contest_id), '[]'::jsonb),
    -- 4. juries_bundles
    COALESCE((
      SELECT jsonb_agg(
        jsonb_build_object(
          'jury', to_jsonb(j),
          'jurations_bundles', (SELECT COALESCE(jsonb_agg(jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))), '[]'::jsonb) FROM public.jurations ju JOIN public.profiles p_juror ON ju.juror_id = p_juror.id WHERE ju.jury_id = j.id),
          'jurors_invitations', (SELECT COALESCE(jsonb_agg(to_jsonb(ji)), '[]'::jsonb) FROM public.juror_invitations ji WHERE ji.jury_id = j.id),
          'voting_form_bundle', (SELECT jsonb_build_object('voting_form', to_jsonb(vf), 'voting_form_fields', COALESCE((SELECT jsonb_agg(to_jsonb(vff)) FROM public.voting_form_fields vff WHERE vff.voting_form_id = vf.id), '[]'::jsonb)) FROM public.voting_forms vf WHERE vf.id = j.voting_form_id)
        )
      )
      FROM public.juries j WHERE j.contest_id = p_contest_id
    ), '[]'::jsonb),
    -- 5. voting_sessions
    COALESCE((SELECT jsonb_agg(to_jsonb(vs)) FROM public.voting_sessions vs WHERE vs.contest_id = p_contest_id), '[]'::jsonb);
END;
$$;


--region CREATE CONTEST
-- Crea un 'place' e un 'contest' in una singola transazione atomica.
-- Se una delle due operazioni fallisce, l'intera transazione viene annullata.
CREATE OR REPLACE FUNCTION create_contest(p_contest jsonb, p_place jsonb)
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
CREATE OR REPLACE FUNCTION update_contest(p_contest jsonb, p_place jsonb)
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


--region GET PARTICIPATION BUNDLE
-- Recupera i dettagli di una partecipazione (partecipazione, partecipante e opera).
CREATE OR REPLACE FUNCTION get_participation_bundle(p_participation_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest a cui appartiene la partecipazione.
  IF NOT EXISTS (
    SELECT 1
    FROM public.participations pa
    JOIN public.contests c ON pa.contest_id = c.id
    WHERE pa.id = p_participation_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Partecipazione non trovata o accesso non autorizzato.';
  END IF;

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


--region INVITE PARTICIPANT
-- Crea un invito per un partecipante.
CREATE OR REPLACE FUNCTION invite_participant(p_participant_invitation jsonb)
RETURNS participant_invitations
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_contest_id uuid := (p_participant_invitation->>'contest_id')::uuid;
  new_invitation participant_invitations;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
  END IF;

  INSERT INTO public.participant_invitations (contest_id, email)
  VALUES (v_contest_id, p_participant_invitation->>'email')
  RETURNING * INTO new_invitation;

  RETURN new_invitation;
END;
$$;


--region INVITE JUROR
-- Crea un invito per un giurato.
CREATE OR REPLACE FUNCTION invite_juror(p_juror_invitation jsonb)
RETURNS juror_invitations
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_contest_id uuid := (p_juror_invitation->>'contest_id')::uuid;
  new_invitation juror_invitations;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
  END IF;

  INSERT INTO public.juror_invitations (contest_id, jury_id, email)
  VALUES (
    v_contest_id,
    (p_juror_invitation->>'jury_id')::uuid,
    p_juror_invitation->>'email'
  )
  RETURNING * INTO new_invitation;

  RETURN new_invitation;
END;
$$;


--region CREATE JURY
-- Crea una 'jury' e il suo 'voting_form' associato in una transazione.
CREATE OR REPLACE FUNCTION create_jury(p_jury jsonb)
RETURNS juries
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_contest_id uuid := (p_jury->>'contest_id')::uuid;
  v_voting_form_id uuid;
  new_jury_row juries;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
  END IF;

  -- 1. Crea un nuovo voting_form.
  INSERT INTO public.voting_forms (created_at) VALUES (now())
  RETURNING id INTO v_voting_form_id;

  -- 2. Crea la nuova giuria.
  INSERT INTO public.juries (contest_id, name, voting_form_id)
  VALUES (v_contest_id, p_jury->>'name', v_voting_form_id)
  RETURNING * INTO new_jury_row;

  RETURN new_jury_row;
END;
$$;


--region UPDATE VOTING FORM
-- Aggiorna i campi di un form di voto (operazione di delete-then-insert).
CREATE OR REPLACE FUNCTION update_voting_form(p_voting_form_id uuid, p_voting_form_fields jsonb)
RETURNS SETOF voting_form_fields
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  field_record record;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest associato.
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_forms vf
    JOIN public.juries j ON vf.id = j.voting_form_id
    JOIN public.contests c ON j.contest_id = c.id
    WHERE vf.id = p_voting_form_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Form di voto non trovato o accesso non autorizzato.';
  END IF;

  -- 1. Cancella tutti i campi esistenti per questo form.
  DELETE FROM public.voting_form_fields WHERE voting_form_id = p_voting_form_id;

  -- 2. Inserisce i nuovi campi dal JSON.
  RETURN QUERY
  INSERT INTO public.voting_form_fields (voting_form_id, name, order_index, min_value, max_value)
  SELECT
    p_voting_form_id,
    (f->>'name')::varchar,
    (f->>'order_index')::int,
    (f->>'min_value')::numeric,
    (f->>'max_value')::numeric
  FROM jsonb_array_elements(p_voting_form_fields) AS f
  RETURNING *;
END;
$$;


--region GET JURY BUNDLE
-- Recupera i dettagli completi di una singola giuria.
CREATE OR REPLACE FUNCTION get_jury_bundle(p_jury_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest a cui appartiene la giuria.
  IF NOT EXISTS (
    SELECT 1
    FROM public.juries j
    JOIN public.contests c ON j.contest_id = c.id
    WHERE j.id = p_jury_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Giuria non trovata o accesso non autorizzato.';
  END IF;

  SELECT jsonb_build_object(
    'jury', (SELECT to_jsonb(j) FROM public.juries j WHERE j.id = p_jury_id),
    'jurations_bundles', COALESCE((SELECT jsonb_agg(jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))) FROM public.jurations ju JOIN public.profiles p_juror ON ju.juror_id = p_juror.id WHERE ju.jury_id = p_jury_id), '[]'::jsonb),
    'jurors_invitations', COALESCE((SELECT jsonb_agg(to_jsonb(ji)) FROM public.juror_invitations ji WHERE ji.jury_id = p_jury_id), '[]'::jsonb),
    'voting_form_bundle', (SELECT jsonb_build_object('voting_form', to_jsonb(vf), 'voting_form_fields', COALESCE((SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index) FROM public.voting_form_fields vff WHERE vff.voting_form_id = vf.id), '[]'::jsonb)) FROM public.voting_forms vf WHERE vf.id = (SELECT voting_form_id FROM public.juries WHERE id = p_jury_id))
  ) INTO result_bundle;

  RETURN result_bundle;
END;
$$;


-- Aggiungi questo blocco alla fine del tuo file rpc_organizer.sql

--region GET VOTING FORM BUNDLE
-- Recupera un form di voto e tutti i suoi campi associati.
-- Utile per la pagina di modifica del form.
CREATE OR REPLACE FUNCTION get_voting_form_bundle(p_voting_form_id uuid)
RETURNS TABLE (
  voting_form jsonb,
  voting_form_fields jsonb
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER -- Eseguita con i permessi dell'utente, rispetta le RLS.
AS $$
BEGIN
  -- SICUREZZA: Verifica che l'utente che chiama la funzione sia l'organizzatore
  -- del contest a cui questo form di voto appartiene.
  -- La catena di join è: voting_forms -> juries -> contests
  IF NOT EXISTS (
    SELECT 1
    FROM public.voting_forms vf
    JOIN public.juries j ON vf.id = j.voting_form_id
    JOIN public.contests c ON j.contest_id = c.id
    WHERE vf.id = p_voting_form_id AND c.organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Form di voto non trovato o accesso non autorizzato.';
  END IF;

  -- Esegue la query per costruire il bundle
  RETURN QUERY
  SELECT
    -- 1. L'oggetto JSON del form di voto.
    (SELECT to_jsonb(vf) FROM public.voting_forms vf WHERE vf.id = p_voting_form_id) AS voting_form,

    -- 2. Un array JSON dei campi del form, ordinati per 'order_index'.
    --    COALESCE gestisce il caso in cui non ci siano campi, restituendo un array vuoto '[]'.
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
        FROM public.voting_form_fields vff
        WHERE vff.voting_form_id = p_voting_form_id
      ),
      '[]'::jsonb
    ) AS voting_form_fields;
END;
$$;


--region GET JOINED CONTESTS AS PARTICIPANT
-- Recupera una lista di contest a cui l'utente autenticato si è unito.
CREATE OR REPLACE FUNCTION get_joined_contests_as_participant()
RETURNS TABLE (
  contest_bundle jsonb,
  participations jsonb,
  jurations jsonb
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER -- Eseguita con i permessi dell'utente chiamante.
AS $$
BEGIN
  -- È buona norma verificare che il profilo del partecipante esista.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Profilo utente con ID % non trovato.', auth.uid();
  END IF;

  -- Esegue la query e restituisce i risultati.
  -- La differenza chiave rispetto a get_created_contests è il JOIN aggiuntivo
  -- sulla tabella 'participations' per filtrare i contest in base all'utente corrente.
  RETURN QUERY
  SELECT
    -- 1. Costruisce l'oggetto JSON 'contest_bundle'. (Identico a get_created_contests)
    jsonb_build_object(
      'contest', to_jsonb(c),
      'organizer', to_jsonb(p),
      'place', to_jsonb(pl)
    ) AS contest_bundle,

    -- 2. Aggrega tutte le partecipazioni del contest. (Identico a get_created_contests)
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(pa))
        FROM public.participations AS pa
        WHERE pa.contest_id = c.id
      ),
      '[]'::jsonb
    ) AS participations,

    -- 3. Aggrega tutte le giurie del contest. (Identico a get_created_contests)
    COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(ju))
        FROM public.jurations AS ju
        WHERE ju.contest_id = c.id
      ),
      '[]'::jsonb
    ) AS jurations
  FROM
    public.contests AS c
    -- JOIN per ottenere i dettagli del profilo dell'organizzatore.
    JOIN public.profiles AS p ON c.organizer_id = p.id
    -- JOIN per ottenere i dettagli del luogo del contest.
    JOIN public.places AS pl ON c.place_id = pl.id
    -- *** LOGICA CHIAVE ***
    -- JOIN con la tabella participations per trovare i contest a cui l'utente partecipa.
    JOIN public.participations user_participation ON c.id = user_participation.contest_id
  WHERE
    -- Filtra per l'ID del partecipante che ha chiamato la funzione.
    user_participation.participant_id = auth.uid()
  ORDER BY
      c.created_at DESC;
END;
$$;


--region PARTICIPANT JOIN CONTEST
-- Permette a un utente autenticato di unirsi a un contest usando un token di invito.
-- Se l'invito è valido, crea una nuova partecipazione e cancella l'invito.
CREATE OR REPLACE FUNCTION participant_join_contest(p_token text)
RETURNS void -- Non restituisce dati, ma solleva un'eccezione in caso di errore.
LANGUAGE plpgsql
SECURITY INVOKER -- Eseguita con i permessi dell'utente, quindi auth.uid() è disponibile.
AS $$
DECLARE
  v_invitation record; -- Uso 'record' per flessibilità, conterrà la riga dell'invito.
BEGIN
  -- 1. Cerca l'invito usando il token fornito.
  SELECT *
  INTO v_invitation
  FROM public.participant_invitations
  WHERE token = p_token;

  -- 2. Se l'invito non esiste, solleva un'eccezione.
  --    La clausola `IF NOT FOUND` si attiva se la query precedente non ha trovato righe.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invito non valido o già utilizzato.';
  END IF;

  -- 3. Controlla se l'utente è già un partecipante di questo contest per evitare duplicati.
  IF EXISTS (
    SELECT 1
    FROM public.participations
    WHERE contest_id = v_invitation.contest_id AND participant_id = auth.uid()
  ) THEN
    -- Se l'utente è già iscritto, l'operazione è idempotente.
    -- Cancello comunque l'invito per pulizia e termino con successo.
    DELETE FROM public.participant_invitations WHERE id = v_invitation.id;
    RETURN;
  END IF;

  -- 4. Crea la nuova riga nella tabella 'participations'.
  INSERT INTO public.participations (contest_id, participant_id, invitation_email)
  VALUES (v_invitation.contest_id, auth.uid(), v_invitation.email);

  -- 5. Elimina l'invito che è stato appena utilizzato, completando il processo.
  DELETE FROM public.participant_invitations WHERE id = v_invitation.id;

END;
$$;

--region SUBMIT WORK
-- Permette a un partecipante di sottomettere la propria opera per un contest.
-- Esegue controlli di validità (periodo di sottomissione, partecipazione esistente)
-- e aggiorna lo stato in modo transazionale.
CREATE OR REPLACE FUNCTION submit_work(p_contest_id uuid, p_work jsonb)
RETURNS void -- Non restituisce dati, ma solleva un'eccezione in caso di errore.
LANGUAGE plpgsql
SECURITY INVOKER -- Eseguita con i permessi dell'utente, quindi auth.uid() è disponibile.
AS $$
DECLARE
  v_participation record;
  v_contest record;
BEGIN
  -- 1. Recupera i dettagli del contest per controllare le date di sottomissione.
  SELECT *
  INTO v_contest
  FROM public.contests
  WHERE id = p_contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Contest non trovato.';
  END IF;

  -- 2. CONTROLLO CHIAVE: Verifica che la data corrente sia all'interno del periodo di sottomissione.
  IF now() NOT BETWEEN v_contest.works_submission_start AND v_contest.works_submission_end THEN
    RAISE EXCEPTION 'Il periodo per la sottomissione delle opere non è attivo.';
  END IF;

  -- 3. Trova la partecipazione dell'utente corrente per questo contest.
  SELECT *
  INTO v_participation
  FROM public.participations
  WHERE contest_id = p_contest_id AND participant_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Non sei un partecipante di questo contest.';
  END IF;

  -- 4. Controlla se l'utente ha già sottomesso un'opera.
  IF v_participation.has_submitted THEN
    RAISE EXCEPTION 'Hai già sottomesso un''opera per questo contest.';
  END IF;

  -- 5. Crea il nuovo record nella tabella 'works'.
  --    Usa l'ID della partecipazione trovata per collegare l'opera.
  INSERT INTO public.works (
    participation_id,
    participant_full_name,
    name,
    description,
    images_urls,
    file_url
  )
  VALUES (
    v_participation.id,
    p_work->>'participant_full_name',
    p_work->>'name',
    p_work->>'description',
    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_work->'images_urls')),
    p_work->>'file_url'
  );

  -- 6. Aggiorna la tabella 'participations' per segnare che l'opera è stata sottomessa.
  UPDATE public.participations
  SET has_submitted = true
  WHERE id = v_participation.id;

END;
$$;
