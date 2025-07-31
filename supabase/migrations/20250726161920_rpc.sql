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
  voting_sessions_bundles jsonb
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
    -- 5. voting_sessions_bundles -- MODIFICATO: Ora costruisce il bundle corretto
    COALESCE((
      SELECT jsonb_agg(
        jsonb_build_object(
          'voting_session', to_jsonb(vs),
          'geo_res_place', to_jsonb(pl)
        ) ORDER BY vs.created_at DESC
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.contest_id = p_contest_id
    ), '[]'::jsonb);
END;
$$;
--endregion


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
  v_jury_name text := p_jury->>'name'; -- Estraiamo il nome della giuria
  new_jury_row juries;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
  END IF;

  -- 1. Crea un nuovo voting_form, usando il nome della giuria per i campi obbligatori.
  INSERT INTO public.voting_forms (name, description)
  VALUES (
    v_jury_name, -- Usa il nome della giuria come nome del form
    'Voting form for jury: ' || v_jury_name -- Usa una descrizione di default
  )
  RETURNING id INTO v_voting_form_id;

  -- 2. Crea la nuova giuria, collegandola al form appena creato.
  INSERT INTO public.juries (contest_id, name, voting_form_id, type)
  VALUES (v_contest_id, v_jury_name, v_voting_form_id, (p_jury->>'type')::jury_type)
  RETURNING * INTO new_jury_row;

  RETURN new_jury_row;
END;
$$;


 --region UPDATE VOTING FORM
 -- Aggiorna i campi di un form di voto (operazione di delete-then-insert).
 CREATE OR REPLACE FUNCTION update_voting_form (
   p_voting_form_id uuid, -- ID del form da aggiornare
   p_name varchar, -- Nuovo nome per il form
   p_description varchar, -- Nuova descrizione per il form
   p_voting_form_fields jsonb
 )
 RETURNS SETOF voting_form_fields
 LANGUAGE plpgsql
 SECURITY INVOKER
 AS $$
 BEGIN

   -- Aggiorna nome e descrizione del form
   UPDATE public.voting_forms
   SET
     name = p_name,
     description = p_description
   WHERE id = p_voting_form_id;

   -- 1. Cancella tutti i campi esistenti per questo form.
   DELETE FROM public.voting_form_fields WHERE voting_form_id = p_voting_form_id;

   -- 2. Inserisce i nuovi campi dal JSON, allineati alla nuova struttura.
   RETURN QUERY
   INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, is_required, scope, slider_min_value, slider_max_value)
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

--region GET JURY BUNDLE
-- Recupera i dettagli completi di una singola giuria.
CREATE OR REPLACE FUNCTION get_jury_bundle(p_jury_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
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

  SELECT
       jsonb_build_object(
         'jury', to_jsonb(j),
         'jurations_bundles', COALESCE((SELECT jsonb_agg(jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))) FROM public.jurations ju JOIN public.profiles p_juror ON ju.juror_id = p_juror.id WHERE ju.jury_id = j.id), '[]'::jsonb),
         'jurors_invitations', COALESCE((SELECT jsonb_agg(to_jsonb(ji)) FROM public.juror_invitations ji WHERE ji.jury_id = j.id), '[]'::jsonb),
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

--region GET VOTING FORM BUNDLE
-- Recupera un form di voto e tutti i suoi campi associati.
-- Utile per la pagina di modifica del form.
CREATE OR REPLACE FUNCTION get_voting_form_bundle(p_voting_form_id uuid)
RETURNS jsonb -- MODIFICA: Restituisce un singolo oggetto JSONB che mappa direttamente a VotingFormBundle.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
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
    RAISE EXCEPTION 'You are already a participant in this contest. Invitation token deleted';
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
    images_urls
  )
  VALUES (
    v_participation.id,
    p_work->>'participant_full_name',
    p_work->>'name',
    p_work->>'description',
    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_work->'images_urls'))
  );

  -- 6. Aggiorna la tabella 'participations' per segnare che l'opera è stata sottomessa.
  UPDATE public.participations
  SET has_submitted = true
  WHERE id = v_participation.id;

END;
$$;

--region JUROR GET JOINED CONTESTS
-- Recupera una lista di contest a cui l'utente autenticato si è unito come giurato.
CREATE OR REPLACE FUNCTION juror_get_joined_contests()
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
  -- Verifica che il profilo del giurato esista.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Profilo utente con ID % non trovato.', auth.uid();
  END IF;

  -- Esegue la query e restituisce i risultati.
  -- Un utente può essere in più giurie per lo stesso contest, quindi usiamo DISTINCT ON (c.id)
  -- per assicurarci che ogni contest appaia una sola volta nella lista.
  RETURN QUERY
  SELECT DISTINCT ON (c.id)
    -- 1. Costruisce l'oggetto JSON 'contest_bundle'.
    jsonb_build_object(
      'contest', to_jsonb(c),
      'organizer', to_jsonb(p),
      'place', to_jsonb(pl)
    ) AS contest_bundle,

    -- 2. Aggrega tutte le partecipazioni del contest.
    COALESCE(
      (SELECT jsonb_agg(to_jsonb(pa)) FROM public.participations AS pa WHERE pa.contest_id = c.id),
      '[]'::jsonb
    ) AS participations,

    -- 3. Aggrega tutte le giurie del contest.
    COALESCE(
      (SELECT jsonb_agg(to_jsonb(ju)) FROM public.jurations AS ju WHERE ju.contest_id = c.id),
      '[]'::jsonb
    ) AS jurations
  FROM
    public.contests AS c
    JOIN public.profiles AS p ON c.organizer_id = p.id
    JOIN public.places AS pl ON c.place_id = pl.id
    -- *** LOGICA CHIAVE ***
    -- JOIN con la tabella jurations per trovare i contest in cui l'utente è giurato.
    JOIN public.jurations user_juration ON c.id = user_juration.contest_id
  WHERE
    -- Filtra per l'ID del giurato che ha chiamato la funzione.
    user_juration.juror_id = auth.uid()
  ORDER BY
      c.id, c.created_at DESC;
END;
$$;
--endregion


--region JUROR JOIN CONTEST
-- Permette a un utente autenticato di unirsi a una giuria usando un token di invito.
-- Se l'invito è valido, crea una nuova juration e cancella l'invito.
CREATE OR REPLACE FUNCTION juror_join_contest(p_token text)
RETURNS void -- Non restituisce dati, ma solleva un'eccezione in caso di errore.
LANGUAGE plpgsql
SECURITY INVOKER -- Eseguita con i permessi dell'utente, quindi auth.uid() è disponibile.
AS $$
DECLARE
  v_invitation record; -- Conterrà la riga dell'invito.
BEGIN
  -- 1. Cerca l'invito per il giurato usando il token fornito.
  SELECT *
  INTO v_invitation
  FROM public.juror_invitations
  WHERE token = p_token;

  -- 2. Se l'invito non esiste, solleva un'eccezione.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invito non valido o già utilizzato.';
  END IF;

  -- 3. Controlla se l'utente è già membro di questa specifica giuria per evitare duplicati.
  IF EXISTS (
    SELECT 1
    FROM public.jurations
    WHERE jury_id = v_invitation.jury_id AND juror_id = auth.uid()
  ) THEN
    -- Se l'utente è già iscritto, l'operazione è idempotente.
    -- Cancello comunque l'invito per pulizia e termino con successo.
    DELETE FROM public.juror_invitations WHERE id = v_invitation.id;
    RAISE EXCEPTION 'You are already a juror in this contest. Invitation token deleted';
  END IF;

  -- 4. Crea la nuova riga nella tabella 'jurations'.
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email)
  VALUES (v_invitation.contest_id, v_invitation.jury_id, auth.uid(), v_invitation.email);

  -- 5. Elimina l'invito che è stato appena utilizzato, completando il processo.
  DELETE FROM public.juror_invitations WHERE id = v_invitation.id;

END;
$$;
--endregion

--region ORGANIZER REGENERATE CONTEST TOKEN
-- Rigenera il token di invito per un contest specifico.
-- Esegue un controllo per assicurarsi che solo l'organizzatore possa eseguire questa azione.
CREATE OR REPLACE FUNCTION organizer_regenerate_contest_token(p_contest_id uuid)
RETURNS void -- Non restituisce dati, ma solleva un'eccezione in caso di errore.
LANGUAGE plpgsql
SECURITY INVOKER -- Eseguita con i permessi dell'utente, quindi auth.uid() è disponibile.
AS $$
DECLARE
  v_new_token text;
BEGIN
  -- 1. SICUREZZA: Verifica che l'utente che chiama la funzione sia l'organizzatore del contest.
  --    Questo è il passo più importante per prevenire accessi non autorizzati.
  IF NOT EXISTS (
    SELECT 1
    FROM public.contests
    WHERE id = p_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
  END IF;

  -- 2. Genera un nuovo token unico usando la tua funzione di utilità.
  --    La lunghezza 14 è basata sulla definizione della tabella 'contests'.
  v_new_token := gen_unique_token('contests', 'token', 14);

  -- 3. Aggiorna il token del contest specificato con il nuovo valore.
  UPDATE public.contests
  SET token = v_new_token
  WHERE id = p_contest_id;

END;
$$;
--endregion

--region GET VOTING SESSION PROCEDURE BUNDLE
-- Recupera tutti i dati necessari per la conduzione di una sessione di voto.
-- Restituisce un singolo oggetto JSON che mappa la classe Dart 'VotingSessionProcedureBundle'.
CREATE OR REPLACE FUNCTION get_voting_session_procedure_bundle(p_voting_session_id uuid)
RETURNS jsonb -- Restituisce un singolo oggetto JSONB, non una tabella.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- NOTA DI SICUREZZA: Il controllo di autorizzazione è commentato.
  -- Assicurati che sia gestito correttamente dalle tue policy RLS o riabilitalo.
--  IF NOT EXISTS (
--    SELECT 1
--    FROM public.voting_sessions vs
--    JOIN public.contests c ON vs.contest_id = c.id
--    WHERE vs.id = p_voting_session_id AND c.organizer_id = auth.uid()
--  ) THEN
--    RAISE EXCEPTION 'Voting session not found or access not authorized.';
--  END IF;

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

    -- 2. 'voting_session_participations'
    'voting_session_participations', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participations vsp
      WHERE vsp.voting_session_id = p_voting_session_id
    ),

    -- 3. 'voting_session_juries_bundles'
    'voting_session_juries_bundles', (
      SELECT COALESCE(
        jsonb_agg(
          -- Per ogni giuria della sessione, costruisce il suo bundle
          jsonb_build_object(
            'voting_session_jury', to_jsonb(vsj),
            'voting_form_bundle', (
                SELECT jsonb_build_object(
                    'voting_form', to_jsonb(vf),
                    'voting_form_fields', COALESCE(
                        (SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
                         FROM public.voting_form_fields vff
                         WHERE vff.voting_form_id = vf.id),
                        '[]'::jsonb
                    )
                )
                FROM public.voting_forms vf
                WHERE vf.id = vsj.voting_form_id
            ),
            'voting_session_jurations', (
              -- Subquery per trovare tutti i giurati di questa specifica giuria
              SELECT COALESCE(jsonb_agg(to_jsonb(vsju)), '[]'::jsonb)
              FROM public.voting_session_jurations vsju
              WHERE vsju.voting_session_jury_id = vsj.id
            )
          )
        ),
        '[]'::jsonb
      )
      FROM public.voting_session_juries vsj
      WHERE vsj.voting_session_id = p_voting_session_id
    ),

    -- 4. 'voting_session_exclusions' (MODIFICA: Aggiunto questo blocco)
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

--region ORGANIZER END VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_end_voting_session(p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.voting_sessions
  SET
    session_status = 'ended'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Voting session not found or already ended.';
  END IF;
END;
$$;
--endregion

--region ORGANIZER CANCEL VOTING SESSION
CREATE OR REPLACE FUNCTION organizer_cancel_voting_session (p_voting_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.voting_sessions
  SET
    session_status = 'cancelled'
  WHERE id = p_voting_session_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Voting session not found.';
  END IF;
END;
$$;
--endregion

--region JUROR GET OWN VOTING SESSION JURATION
-- Recupera la specifica riga 'voting_session_juration' per l'utente autenticato
-- all'interno di una data sessione di voto.
CREATE OR REPLACE FUNCTION juror_get_own_voting_session_juration(p_voting_session_id uuid)
RETURNS voting_session_jurations -- Restituisce l'intera riga della tabella.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER -- Eseguita con i permessi dell'utente, quindi auth.uid() è disponibile.
AS $$
DECLARE
  v_result voting_session_jurations;
BEGIN
  -- 1. Esegue una query che collega la sessione di voto all'utente corrente.
  --    La catena di join è: voting_session_jurations -> jurations -> profiles (implicito tramite auth.uid()).
  SELECT vsju.*
  INTO v_result
  FROM public.voting_session_jurations AS vsju
  JOIN public.jurations AS ju ON vsju.juration_id = ju.id
  WHERE
    vsju.voting_session_id = p_voting_session_id
    AND ju.juror_id = auth.uid(); -- Filtra per l'utente che ha chiamato la funzione.

  -- 2. Se non viene trovata nessuna riga, significa che l'utente non è un giurato
  --    in questa sessione, quindi solleva un'eccezione.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Juration per l''utente corrente non trovata in questa sessione di voto.';
  END IF;

  -- 3. Restituisce la riga trovata.
  RETURN v_result;
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
  v_original_form_header text;
  v_original_form_footer text;
BEGIN
  -- SICUREZZA: Verifica che l'utente sia l'organizzatore del contest.
  IF NOT EXISTS (
    SELECT 1 FROM public.contests
    WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Contest non trovato o accesso non autorizzato.';
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
  INSERT INTO public.voting_session_participations (
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
    -- 4.a: Get the header from the original voting form.
    SELECT header, footer INTO v_original_form_header, v_original_form_footer
    FROM public.voting_forms
    WHERE id = v_jury_record.voting_form_id;

    -- 4.b: Crea un NUOVO voting_form per lo snapshot, copying the header and footer.
    INSERT INTO public.voting_forms (header, footer) VALUES (v_original_form_header, v_original_form_footer)
    RETURNING id INTO v_new_voting_form_id;

    -- 4.c: Copia i campi dal form originale al nuovo form.
    INSERT INTO public.voting_form_fields (voting_form_id, name, order_index, type, min_value, max_value, is_required)
    SELECT
      v_new_voting_form_id,
      vff.name, vff.order_index, vff.type, vff.min_value, vff.max_value, vff.is_required
    FROM public.voting_form_fields vff
    WHERE vff.voting_form_id = v_jury_record.voting_form_id;

    -- 4.d: Crea lo snapshot della giuria.
    INSERT INTO public.voting_session_juries (
      voting_session_id, jury_id, jury_name, voting_form_id, token
    ) VALUES (
      v_session_id, v_jury_record.id, v_jury_record.name, v_new_voting_form_id, v_jury_record.token
    )
    RETURNING id INTO v_session_jury_id;

    -- 4.e: Crea gli snapshot dei singoli giurati.
    INSERT INTO public.voting_session_jurations (
      voting_session_id, juration_id, voting_session_jury_id, juror_full_name
    )
    SELECT
      v_session_id,
      ju.id,
      v_session_jury_id,
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
    voting_session_juration_id,
    voting_session_participation_id
  )
  SELECT
    v_session_id,
    vsj.id,
    vsp.id
  FROM
    jsonb_to_recordset(p_exclusions) AS x(juration_id uuid, participation_id uuid)
    JOIN public.voting_session_jurations vsj ON vsj.juration_id = x.juration_id AND vsj.voting_session_id = v_session_id
    JOIN public.voting_session_participations vsp ON vsp.participation_id = x.participation_id AND vsp.voting_session_id = v_session_id;

  -- 6. Recupera e restituisce la riga completa della sessione appena creata.
  SELECT * INTO v_new_session FROM public.voting_sessions WHERE id = v_session_id;
  RETURN v_new_session;
END;
$$;
--endregion

--region JUROR SUBMIT VOTES (REFACTORED FOR NEW SCHEMA)
-- Permette a un giurato di inviare i suoi voti per una sessione.
-- L'operazione è transazionale e usa il nuovo schema flessibile.
CREATE OR REPLACE FUNCTION juror_submit_votes(
  p_voting_session_id uuid,
  -- MODIFICA: Il payload è ora una lista piatta di tutti i valori.
  -- Esempio: '[{"form_field_id": "...", "value": "...", "voting_session_participation_id": "..."}, ...]'
  -- 'voting_session_participation_id' è NULL per i campi di scope 'header' o 'footer'.
  p_votes_payload jsonb,
  p_juror_lat float DEFAULT NULL,
  p_juror_lon float DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_session record;
  v_juration voting_session_jurations;
  v_geo_res_place record;
  v_submission_id uuid; -- ID della nuova riga in form_submissions
BEGIN
  -- PASSO 1: CONTROLLI DI SICUREZZA (Invariati)
  -- Recupera la juration dell'utente per questa sessione.
  SELECT * INTO v_juration
  FROM public.juror_get_own_voting_session_juration(p_voting_session_id);

  -- Controlla se ha già sottomesso i voti.
  IF v_juration.has_submitted THEN
    RAISE EXCEPTION 'I voti per questa sessione sono già stati inviati.';
  END IF;

  -- Controlla lo stato della sessione.
  SELECT * INTO v_session FROM public.voting_sessions WHERE id = p_voting_session_id;
  IF v_session.session_status <> 'live' THEN
    RAISE EXCEPTION 'La sessione di voto non è attiva.';
  END IF;

  -- PASSO 2: CONTROLLO GEO-RESTRIZIONE (Invariato)
  IF v_session.is_geo_restricted THEN
    IF p_juror_lat IS NULL OR p_juror_lon IS NULL THEN
      RAISE EXCEPTION 'Dati di localizzazione richiesti per questa sessione di voto.';
    END IF;
    SELECT * INTO v_geo_res_place FROM public.places WHERE id = v_session.geo_res_place_id;
    -- Usa PostGIS per verificare la distanza.
    IF NOT ST_DWithin(
      ST_MakePoint(v_geo_res_place.lon, v_geo_res_place.lat)::geography,
      ST_MakePoint(p_juror_lon, p_juror_lat)::geography,
      v_session.geo_res_radius
    ) THEN
      RAISE EXCEPTION 'Non ti trovi all''interno dell''area geografica consentita per la votazione.';
    END IF;
  END IF;

  -- PASSO 3: SALVATAGGIO DEI VOTI (Logica completamente nuova)
  -- 3a. Crea una singola riga in 'form_submissions' per rappresentare questo invio.
  INSERT INTO public.voting_form_submissions (
    voting_session_id,
    voting_session_juration_id
  ) VALUES (
    p_voting_session_id,
    v_juration.id
  )
  RETURNING id INTO v_submission_id; -- Cattura l'ID della sottomissione.

  -- 3b. Inserisce tutti i valori dei voti in 'form_submission_values' con un'unica operazione.
  --      Questo è molto più efficiente di un loop.
  INSERT INTO public.voting_form_submission_values (
    voting_form_submission_id,
    voting_form_field_id,
    value,
    voting_session_participation_id
  )
  SELECT
    v_submission_id, -- Usa l'ID della sottomissione appena creato per tutti i valori.
    (value->>'voting_form_field_id')::uuid,
    (value->>'value')::text,
    (value->>'voting_session_participation_id')::uuid -- Sarà NULL se la chiave non è presente nel JSON.
  FROM jsonb_array_elements(p_votes_payload) AS value;

  -- PASSO 4: AGGIORNA LO STATO DEL GIURATO (Invariato)
  UPDATE public.voting_session_jurations
  SET has_submitted = true
  WHERE id = v_juration.id;

END;
$$;
--endregion

--region GET VOTING SESSION RESULT DETAILS (REFACTORED)
-- Recupera tutti i dati necessari per visualizzare i risultati di una sessione di voto.
-- Restituisce un singolo oggetto JSON con dati già aggregati per semplificare il client.
CREATE OR REPLACE FUNCTION get_voting_session_result_details(p_voting_session_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  v_contest_id uuid;
BEGIN
  -- Controllo di sicurezza per verificare che l'utente sia l'organizzatore.
  SELECT contest_id INTO v_contest_id FROM public.voting_sessions WHERE id = p_voting_session_id;
  IF NOT EXISTS (
    SELECT 1 FROM public.contests WHERE id = v_contest_id AND organizer_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Sessione di voto non trovata o accesso non autorizzato.';
  END IF;

  -- Costruisce l'oggetto JSON finale.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle': Contiene la sessione e il suo place.
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = p_voting_session_id
    ),

    -- 2. 'voting_session_participations': Snapshot dei partecipanti (già pulito).
    'voting_session_participations', COALESCE((
      SELECT jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index)
      FROM public.voting_session_participations vsp
      WHERE vsp.voting_session_id = p_voting_session_id
    ), '[]'::jsonb),

    -- 3. 'voting_session_juries_bundles': Struttura complessa già costruita.
    'voting_session_juries_bundles', (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'voting_session_jury', to_jsonb(vsj),
          'voting_form_bundle', (
            SELECT jsonb_build_object(
              'voting_form', to_jsonb(vf),
              'voting_form_fields', COALESCE((
                SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
                FROM public.voting_form_fields vff
                WHERE vff.voting_form_id = vf.id
              ), '[]'::jsonb)
            )
            FROM public.voting_forms vf
            WHERE vf.id = vsj.voting_form_id
          ),
          'voting_session_jurations', (
            SELECT COALESCE(jsonb_agg(to_jsonb(vsju)), '[]'::jsonb)
            FROM public.voting_session_jurations vsju
            WHERE vsju.voting_session_jury_id = vsj.id
          )
        )
      ), '[]'::jsonb)
      FROM public.voting_session_juries vsj
      WHERE vsj.voting_session_id = p_voting_session_id
    ),

    -- 4. 'voting_session_exclusions': Lista delle esclusioni.
    'voting_session_exclusions', COALESCE((
      SELECT jsonb_agg(to_jsonb(vse))
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_id = p_voting_session_id
    ), '[]'::jsonb),

    -- 5. Dati grezzi dei voti (che verranno mappati dal client).
    'raw_jurors_votings', COALESCE((
      SELECT jsonb_agg(to_jsonb(jv))
      FROM public.juror_votings jv
      WHERE jv.voting_session_id = p_voting_session_id
    ), '[]'::jsonb),
    'raw_jurors_votes', COALESCE((
      SELECT jsonb_agg(to_jsonb(jvv))
      FROM public.juror_votes jvv
      JOIN public.juror_votings jv ON jvv.juror_voting_id = jv.id
      WHERE jv.voting_session_id = p_voting_session_id
    ), '[]'::jsonb)

  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region GET VOTING SESSION JURY RESULT DETAILS (BY SINGLE ID)
-- Recupera i risultati di una sessione di voto, ma filtrati per una singola giuria della sessione.
-- Usa un singolo ID (p_voting_session_jury_id) per una maggiore specificità e semplicità.
CREATE OR REPLACE FUNCTION organizer_get_voting_session_jury_result_details(
  p_voting_session_jury_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  v_voting_session_id uuid;
  v_jury_id uuid;
BEGIN
  -- LOGICA CHIAVE: Recupera gli ID necessari dalla tabella voting_session_juries
  SELECT voting_session_id, jury_id
  INTO v_voting_session_id, v_jury_id
  FROM public.voting_session_juries
  WHERE id = p_voting_session_jury_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Sessione di giuria non trovata con ID %', p_voting_session_jury_id;
  END IF;

  -- SICUREZZA: Verifica che l'utente che chiama la funzione sia un membro della giuria originale.
  -- Questo permette a un giurato di vedere i risultati della propria giuria.
  IF NOT EXISTS (
    SELECT 1 FROM public.jurations
    WHERE jury_id = v_jury_id AND juror_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Accesso non autorizzato o giuria non trovata.';
  END IF;

  -- Costruisce l'oggetto JSON finale, filtrando i dati per la giuria specificata.
  SELECT jsonb_build_object(
    -- 'voting_session_bundle' e 'voting_session_participations' usano v_voting_session_id
    'voting_session_bundle', (
      SELECT jsonb_build_object('voting_session', to_jsonb(vs), 'geo_res_place', to_jsonb(pl))
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = v_voting_session_id
    ),

    'voting_session_participations', COALESCE((
      SELECT jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index)
      FROM public.voting_session_participations vsp
      WHERE vsp.voting_session_id = v_voting_session_id
    ), '[]'::jsonb),

    -- MODIFICA CHIAVE: Restituisce un singolo oggetto 'voting_session_jury_bundle' usando p_voting_session_jury_id
    'voting_session_jury_bundle', (
      SELECT
        jsonb_build_object(
          'voting_session_jury', to_jsonb(vsj),
          'voting_form_bundle', (
            SELECT jsonb_build_object(
              'voting_form', to_jsonb(vf),
              'voting_form_fields', COALESCE((SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index) FROM public.voting_form_fields vff WHERE vff.voting_form_id = vf.id), '[]'::jsonb)
            )
            FROM public.voting_forms vf WHERE vf.id = vsj.voting_form_id
          ),
          'voting_session_jurations', (
            SELECT COALESCE(jsonb_agg(to_jsonb(vsju)), '[]'::jsonb)
            FROM public.voting_session_jurations vsju
            WHERE vsju.voting_session_jury_id = vsj.id
          )
        )
      FROM public.voting_session_juries vsj
      WHERE vsj.id = p_voting_session_jury_id -- <-- FILTRO DIRETTO
    ),

    -- 'voting_session_exclusions' viene filtrato per i giurati della giuria specificata.
    'voting_session_exclusions', COALESCE((
      SELECT jsonb_agg(to_jsonb(vse))
      FROM public.voting_session_exclusions vse
      JOIN public.voting_session_jurations vsju ON vse.voting_session_juration_id = vsju.id
      WHERE vsju.voting_session_jury_id = p_voting_session_jury_id
    ), '[]'::jsonb),

    -- 'raw_jurors_votings' e 'raw_jurors_votes' vengono filtrati allo stesso modo.
    'raw_jurors_votings', COALESCE((
      SELECT jsonb_agg(to_jsonb(jv))
      FROM public.juror_votings jv
      JOIN public.voting_session_jurations vsju ON jv.voting_session_juration_id = vsju.id
      WHERE vsju.voting_session_jury_id = p_voting_session_jury_id
    ), '[]'::jsonb),
    'raw_jurors_votes', COALESCE((
      SELECT jsonb_agg(to_jsonb(jvv))
      FROM public.juror_votes jvv
      JOIN public.juror_votings jv ON jvv.juror_voting_id = jv.id
      JOIN public.voting_session_jurations vsju ON jv.voting_session_juration_id = vsju.id
      WHERE vsju.voting_session_jury_id = p_voting_session_jury_id
    ), '[]'::jsonb)

  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion