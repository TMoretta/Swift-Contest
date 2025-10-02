DO $$
BEGIN
  -- Crea il bucket per le immagini dei contest se non esiste già
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'contests-images') THEN
    PERFORM storage.create_bucket(
      'contests-images',
      public => false,
      file_size_limit => 5242880, -- 5MB
      allowed_mime_types => ARRAY['image/jpeg', 'image/png', 'image/webp']
    );
  END IF;

  -- Crea il bucket per le immagini delle opere se non esiste già
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'works-images') THEN
    PERFORM storage.create_bucket(
      'works-images',
      public => false,
      file_size_limit => 5242880, -- 5MB
      allowed_mime_types => ARRAY['image/jpeg', 'image/png', 'image/webp']
    );
  END IF;

  -- Crea il bucket per i PDF delle classifiche se non esiste già
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'contests-rankings') THEN
    PERFORM storage.create_bucket(
      'contests-rankings',
      public => false,
      file_size_limit => 5242880, -- 5MB
      allowed_mime_types => ARRAY['application/pdf']
    );
  END IF;
END $$;

-- todo Create the three policies for select
CREATE POLICY "Allow everything"
ON storage.objects
FOR SELECT
TO authenticated, anon
USING ( true );

---- POLICY DI SICUREZZA PER LO STORAGE
---- Nota: Vengono definite solo le policy di SELECT. Le operazioni di INSERT, UPDATE, DELETE
---- sono gestite lato server (Edge Functions, Triggers) e bypassano RLS usando la service_role_key.
--
---- Helper function to safely cast text to UUID.
---- Returns NULL if the text is not a valid UUID, preventing RLS policies from failing on malformed paths.
--CREATE OR REPLACE FUNCTION public.safe_cast_to_uuid(p_text text)
--RETURNS uuid AS $$
--BEGIN
--  RETURN p_text::uuid;
--EXCEPTION
--  WHEN invalid_text_representation THEN
--    RETURN NULL;
--END;
--$$ LANGUAGE plpgsql IMMUTABLE;
--
---- 1. Permetti la lettura delle immagini dei contest solo agli utenti autorizzati.
----    Un utente è autorizzato se è l'organizzatore, un partecipante o un giurato del contest.
----    Questa policy si basa sulla convenzione che il path di un'immagine inizi con il contest_id.
----    Esempio path: {contest_id}/{...}
--CREATE POLICY "Allow authorized users to read contest images"
--ON storage.objects FOR SELECT
--TO authenticated
--USING (
--  bucket_id = 'contests-images'
--  AND (
--    -- L'utente è l'organizzatore
--    EXISTS (
--      SELECT 1 FROM public.contests c
--      WHERE c.id::text = ((storage.foldername(name))[1]) AND c.organizer_id = auth.uid()
--    )
--    OR
--    -- L'utente è un partecipante
--    EXISTS (
--      SELECT 1 FROM public.participations p
--      WHERE p.contest_id::text = ((storage.foldername(name))[1]) AND p.participant_id = auth.uid()
--    )
--    OR
--    -- L'utente è un giurato
--    EXISTS (
--      SELECT 1 FROM public.jurations j
--      WHERE j.contest_id::text = ((storage.foldername(name))[1]) AND j.juror_id = auth.uid()
--    )
--  )
--);
--
---- 2. Permetti la lettura delle immagini delle opere (works-images) solo agli utenti autorizzati.
----    Questa policy si basa sulla convenzione che il path sia: {contest_id}/{work_id}/{...}
--CREATE POLICY "Allow authorized users to read work images"
--ON storage.objects FOR SELECT
--TO authenticated
--USING (
--  bucket_id = 'works-images'
--  AND (
--    -- Condizione 1: L'utente è l'organizzatore del contest.
--    EXISTS (
--      SELECT 1 FROM public.contests c
--      WHERE c.id = public.safe_cast_to_uuid(split_part(name, '/', 1)) AND c.organizer_id = auth.uid()
--    )
--    OR
--    -- Condizione 2: L'utente è il partecipante che ha sottomesso l'opera.
--    EXISTS (
--      SELECT 1 FROM public.works w
--      JOIN public.participations p ON w.participation_id = p.id
--      WHERE w.id = public.safe_cast_to_uuid(split_part(name, '/', 2)) AND p.participant_id = auth.uid()
--    )
--    OR
--    -- Condizione 3: L'utente è un giurato di una sessione di voto LIVE per quel contest.
--    EXISTS (
--      SELECT 1 FROM public.voting_sessions vs
--      JOIN public.voting_session_jurors vsj ON vs.id = vsj.voting_session_id
--      WHERE vs.contest_id = public.safe_cast_to_uuid(split_part(name, '/', 1))
--        AND vs.session_status = 'live'
--        AND vsj.juror_id = auth.uid()
--    )
--  )
--);
--
---- 3. Permetti la lettura delle classifiche solo agli utenti autorizzati (organizer, participant, juror).
----    Questa policy si basa sulla convenzione che il path sia: {contest_id}/{...}
--CREATE POLICY "Allow authorized users to read contest rankings"
--ON storage.objects FOR SELECT
--TO authenticated
--USING (
--  bucket_id = 'contests-rankings'
--  AND (
--    EXISTS (SELECT 1 FROM public.contests c WHERE c.id = public.safe_cast_to_uuid(split_part(name, '/', 1)) AND c.organizer_id = auth.uid()) OR
--    EXISTS (SELECT 1 FROM public.participations p WHERE p.contest_id = public.safe_cast_to_uuid(split_part(name, '/', 1)) AND p.participant_id = auth.uid()) OR
--    EXISTS (SELECT 1 FROM public.jurations j WHERE j.contest_id = public.safe_cast_to_uuid(split_part(name, '/', 1)) AND j.juror_id = auth.uid())
--  )
--);