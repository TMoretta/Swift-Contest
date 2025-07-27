CREATE TYPE app_theme AS enum('system', 'light', 'dark');

CREATE TYPE contest_role AS enum('organizer', 'participant', 'juror');

CREATE TYPE member_role AS enum('participant', 'juror');

--CREATE TYPE participant_status AS enum('joined', 'out');

--CREATE TYPE juror_status AS enum('joined', 'out');

CREATE TYPE contest_status AS enum(
  'preparationPhase',
  'participationPhase',
  'votingPhase',
  'terminated',
  'deleted'
);

CREATE TYPE voting_session_status AS enum(
  'initialized',
  'work',
  'intermission',
  'review',
  'ended',
  'cancelled'
);
