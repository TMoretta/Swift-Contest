-- ENABLE RLS
DO $$ declare
    r record;
begin
    for r in (select tablename from pg_tables where schemaname = 'public') loop
        execute 'alter table public.' || quote_ident(r.tablename) || ' enable row level security';
    end loop;
end $$;

CREATE POLICY "VotingSessions All"
ON voting_sessions
FOR ALL
TO authenticated
USING (TRUE)
WITH CHECK (TRUE);

-- 1. Abilita RLS sulle tabelle di storage
ALTER TABLE storage.buckets
  ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects
  ENABLE ROW LEVEL SECURITY;

-- 2. Policy full‐access su storage.buckets
CREATE POLICY "buckets: allow all"
  ON storage.buckets
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- 3. Policy full‐access su storage.objects
CREATE POLICY "objects: allow all"
  ON storage.objects
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);