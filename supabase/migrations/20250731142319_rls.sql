-- ENABLE RLS ON ALL TABLES IN PUBLIC SCHEMA
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
    EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY';
  END LOOP;
END $$;

-- POLICIES FOR PUBLIC TABLES
-- Note: These are permissive policies suitable for development.
-- For production, consider more restrictive policies based on your app's logic.

CREATE POLICY "Profiles: allow all"
ON public.profiles
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Messages: allow all"
ON public.messages
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Places: allow all"
ON public.places
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Forms: allow all"
ON public.voting_forms
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Contests: allow all"
ON public.contests
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Juries: allow all"
ON public.juries
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Participant Invitations: allow all"
ON public.participant_invitations
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Juror Invitations: allow all"
ON public.juror_invitations
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Participations: allow all"
ON public.participations
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Works: allow all"
ON public.works
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Jurations: allow all"
ON public.jurations
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Form Fields: allow all"
ON public.voting_form_fields
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Sessions: allow all"
ON public.voting_sessions
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Session Participants: allow all"
ON public.voting_session_participants
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Session Jurors: allow all"
ON public.voting_session_jurors
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Session Exclusions: allow all"
ON public.voting_session_exclusions
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Form Submissions: allow all"
ON public.voting_form_submissions
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Form Submission Values: allow all"
ON public.voting_form_submission_values
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Voting Session Juries: allow all"
ON public.voting_session_juries
FOR ALL
TO authenticated, anon
USING (true)
WITH CHECK (true);





-- Rimuove le policy esistenti per evitare conflitti durante le riesecuzioni.
DROP POLICY IF EXISTS "Allow public read access on buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
-- DROP per le nuove policy separate per la gestione dei file
DROP POLICY IF EXISTS "Owners can read their own files" ON storage.objects;
DROP POLICY IF EXISTS "Owners can update their own files" ON storage.objects;
DROP POLICY IF EXISTS "Owners can delete their own files" ON storage.objects;


-- POLICY DI SICUREZZA PER LO STORAGE

-- Politica sui Buckets
-- 1. Permetti a chiunque (anonimo e autenticato) di VEDERE la lista dei bucket.
--    Questo è generalmente sicuro e non espone dati sensibili.
CREATE POLICY "Allow public read access on buckets"
  ON storage.buckets
  FOR SELECT
  TO anon, authenticated
  USING (true);


-- Politiche sugli Oggetti (i file)
-- 2. Permetti agli utenti AUTENTICATI di CARICARE file.
--    La clausola WITH CHECK è una regola di sicurezza che viene applicata PRIMA dell'inserimento.
CREATE POLICY "Allow authenticated uploads"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    -- L'utente può caricare file solo nei bucket specificati.
    -- Aggiorna questa lista se aggiungi nuovi bucket.
    bucket_id IN ('contests-images', 'works-images')
  );

-- 3. Permetti agli utenti di LEGGERE i propri file.
CREATE POLICY "Owners can read their own files"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING ( auth.uid() = owner );

-- 4. Permetti agli utenti di AGGIORNARE i propri file.
CREATE POLICY "Owners can update their own files"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING ( auth.uid() = owner ); -- Per UPDATE, USING agisce anche come WITH CHECK per prevenire cambi di proprietà

-- 5. Permetti agli utenti di CANCELLARE i propri file.
CREATE POLICY "Owners can delete their own files"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING ( auth.uid() = owner );


---- POLICIES FOR STORAGE
---- 1. Enable RLS on storage tables
--ALTER TABLE storage.buckets
--  ENABLE ROW LEVEL SECURITY;
--ALTER TABLE storage.objects
--  ENABLE ROW LEVEL SECURITY;
--
---- 2. Policy for full access on storage.buckets
--CREATE POLICY "Buckets: allow all"
--  ON storage.buckets
--  FOR ALL
--  TO public
--  USING (true)
--  WITH CHECK (true);
--
---- 3. Policy for full access on storage.objects
--CREATE POLICY "Objects: allow all"
--  ON storage.objects
--  FOR ALL
--  TO public
--  USING (true)
--  WITH CHECK (true);