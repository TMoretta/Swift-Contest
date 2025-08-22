ALTER PUBLICATION supabase_realtime
ADD TABLE messages;

ALTER TABLE public.messages REPLICA IDENTITY FULL;

ALTER PUBLICATION supabase_realtime
ADD TABLE voting_sessions;
