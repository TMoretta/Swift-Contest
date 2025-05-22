CREATE TYPE public.app_theme AS enum('system', 'light', 'dark');

CREATE TYPE public.participant_status AS enum('joined', 'left');

CREATE TYPE public.contest_role AS enum('organizer', 'participant', 'juror');

CREATE TYPE public.form_field_type AS enum('textual', 'numeric');

CREATE TYPE public.member_role AS enum('participant', 'juror');

CREATE TYPE public.juror_status AS enum('joined', 'left');

CREATE TYPE public.contest_status AS enum(
  'preparationPhase',
  'participationPhase',
  'votingPhase',
  'terminated',
  'deleted'
);

CREATE TYPE public.work_status AS enum('submitted', 'attended', 'out');

CREATE TYPE public.voting_session_procedure_step AS enum(
  'preparation',
  'work',
  'intermission',
  'review',
  'end',
  'cancelled'
);