-- ENABLE RLS ON ALL TABLES IN PUBLIC SCHEMA
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
    EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY';
  END LOOP;
END $$;

-- Non dichiaro nessuna policy in modo da impedire qualsiasi operazione non prevista
-- Tutto verrà eseguito con rpc (security definer) e edge functions con controlli interni

-- Questa policy serve perchè il canale realtime viene creato dal supabase client
-- Create a SELECT policy that grants read access to the relevant users.
-- This allows them to subscribe to realtime changes for the sessions they are involved in.
CREATE POLICY "Allow read access to organizers and involved jurors"
ON public.voting_sessions
FOR SELECT
USING (
 -- Condition 1: The user is the organizer of the contest.
 (EXISTS (
   SELECT 1 FROM public.contests c
   WHERE c.id = voting_sessions.contest_id AND c.organizer_id = auth.uid()
 ))
 OR
 -- Condition 2: The user is a juror participating in this specific voting session.
 (EXISTS (
   SELECT 1 FROM public.voting_session_jurors vsj
   WHERE vsj.voting_session_id = voting_sessions.id AND vsj.juror_id = auth.uid()
 ))
);
--endregion

-- POLICIES FOR PUBLIC TABLES
-- Note: These are permissive policies suitable for development.
-- For production, consider more restrictive policies based on your app's logic.

--CREATE POLICY "Profiles: allow all"
--ON public.profiles
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);

--CREATE POLICY "Messages: allow all"
--ON public.messages
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);

--CREATE POLICY "Places: allow all"
--ON public.places
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Forms: allow all"
--ON public.voting_forms
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);

--CREATE POLICY "Contests: allow all"
--ON public.contests
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Juries: allow all"
--ON public.juries
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Participant Invitations: allow all"
--ON public.participant_invitations
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Juror Invitations: allow all"
--ON public.juror_invitations
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Participations: allow all"
--ON public.participations
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Works: allow all"
--ON public.works
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Jurations: allow all"
--ON public.jurations
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Form Fields: allow all"
--ON public.voting_form_fields
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Sessions: allow all"
--ON public.voting_sessions
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Session Participants: allow all"
--ON public.voting_session_participants
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Session Jurors: allow all"
--ON public.voting_session_jurors
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Session Exclusions: allow all"
--ON public.voting_session_exclusions
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Form Submissions: allow all"
--ON public.voting_form_submissions
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Form Submission Values: allow all"
--ON public.voting_form_submission_values
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Voting Session Juries: allow all"
--ON public.voting_session_juries
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
--
--CREATE POLICY "Contest Rankings: allow all"
--ON public.contest_rankings
--FOR ALL
--TO authenticated, anon
--USING (true)
--WITH CHECK (true);
