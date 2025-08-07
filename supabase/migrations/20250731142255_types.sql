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
  'appointed',
  'simple'
);

 CREATE TYPE voting_form_field_scope AS ENUM (
   'header',     -- Un campo che appare una sola volta per l'intero form/sottomissione.
   'participant', -- Un campo che viene ripetuto per ogni partecipante.
   'footer'
 );
