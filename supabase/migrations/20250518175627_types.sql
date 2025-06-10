CREATE TYPE public.app_theme AS enum('system', 'light', 'dark');

CREATE TYPE public.contest_role AS enum('organizer', 'participant', 'juror');

CREATE TYPE public.member_role AS enum('participant', 'juror');

CREATE TYPE public.participant_status AS enum('joined', 'left');

CREATE TYPE public.juror_status AS enum('joined', 'left');

CREATE TYPE public.contest_status AS enum(
  'preparationPhase',
  'participationPhase',
  'votingPhase',
  'terminated',
  'deleted'
);

CREATE TYPE public.voting_session_status AS enum(
  'initialized',
  'work',
  'intermission',
  'review',
  'ended',
  'cancelled'
);
