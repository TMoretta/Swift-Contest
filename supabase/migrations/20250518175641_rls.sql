-- ENABLE RLS
DO $$ declare
    r record;
begin
    for r in (select tablename from pg_tables where schemaname = 'public') loop
        execute 'alter table public.' || quote_ident(r.tablename) || ' enable row level security';
    end loop;
end $$;

-- POLICIES
-- CONTESTS
CREATE POLICY "Contests All" ON public.contests FOR ALL TO authenticated,
anon USING (TRUE);

-- JURATIONS
CREATE POLICY "Jurations All" ON public.jurations FOR ALL TO authenticated,
anon USING (TRUE);

-- PARTICIPATIONS
CREATE POLICY "Participations All" ON public.participations FOR ALL TO authenticated,
anon USING (TRUE);

-- INVITATIONS
CREATE POLICY "Invitations All" ON public.invitations FOR ALL TO authenticated,
anon USING (TRUE);

-- PLACES
CREATE POLICY "Places All" ON public.places FOR ALL TO authenticated,
anon USING (TRUE);

-- PROFILES
CREATE POLICY "Profiles All" ON public.profiles FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTES
CREATE POLICY "JurorVotes All" ON public.juror_votes FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTING FORM FIELDS
CREATE POLICY "VotingFormFields All" ON public.voting_form_fields FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTING FORMS
CREATE POLICY "VotingForms All" ON public.voting_forms FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTINGS
CREATE POLICY "JurorVotings All" ON public.juror_votings FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTING SESSION JURATIONS
CREATE POLICY "VotingSessionJurations All" ON public.voting_session_jurations FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTING SESSION PARTICIPATIONS
CREATE POLICY "VotingSessionParticipations All" ON public.voting_session_participations FOR ALL TO authenticated,
anon USING (TRUE);

-- VOTING SESSIONS
CREATE POLICY "VotingSessions All" ON public.voting_sessions FOR ALL TO authenticated,
anon USING (TRUE);

-- WORKS
CREATE POLICY "Works All" ON public.works FOR ALL TO authenticated,
anon USING (TRUE);

CREATE POLICY "VotingSessionSimpleJurors All" ON public.voting_session_simple_jurors FOR ALL TO authenticated,
anon USING (TRUE);

CREATE POLICY "SimpleJurorVotings All" ON public.simple_juror_votings FOR ALL TO authenticated,
anon USING (TRUE);

CREATE POLICY "SimpleJurorVotes All" ON public.simple_juror_votes FOR ALL TO authenticated,
anon USING (TRUE);

CREATE POLICY "SimpleJurors All" ON public.simple_jurors FOR ALL TO authenticated,
anon USING (TRUE);

CREATE POLICY "VotingSessionExclusions All" ON public.voting_session_exclusions FOR ALL TO authenticated,
anon USING (TRUE);

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