ALTER PUBLICATION supabase_realtime
ADD TABLE voting_sessions;

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