-- Questo blocco di codice usa DO per eseguire logica procedurale.
-- Controlla se i bucket esistono prima di tentare di crearli,
-- rendendo la migration sicura da eseguire più volte.

DO $$
BEGIN
  -- Crea il bucket per le immagini dei contest se non esiste già
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'contests-images') THEN
    PERFORM storage.create_bucket(
      'contests-images',
      public => false,
      file_size_limit => 5242880,
      allowed_mime_types => ARRAY['image/jpeg', 'image/png', 'image/webp']
    );
  END IF;

  -- Crea il bucket per le immagini delle opere se non esiste già
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE name = 'works-images') THEN
    PERFORM storage.create_bucket(
      'works-images',
      public => false,
      file_size_limit => 5242880,
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