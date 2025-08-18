CREATE TYPE app_theme AS enum ('system', 'light', 'dark');

CREATE TYPE contest_role AS enum ('organizer', 'participant', 'juror');

CREATE TYPE voting_session_status AS enum (
  'live',
  'ended',
  'cancelled'
);

CREATE TYPE voting_form_field_type AS enum (
  'textual',
  'slider'
);

CREATE TYPE jury_type AS enum (
  'appointed', -- jury of invited jurors
  'simple' -- jury of jurors that vote only, they access voting with the token
);

CREATE TYPE voting_form_field_scope AS ENUM (
  'header', -- initial form
  'participant', -- this form is repeated for each participant
  'footer' --ending form
);
