CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE cascade,
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name varchar NOT NULL,
  pref_role contest_role NOT NULL DEFAULT 'organizer'
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  account_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  title text NOT NULL,
  body text NOT NULL,
  is_read bool NOT NULL DEFAULT false
);

CREATE TABLE places (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  address varchar NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE voting_forms (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name varchar NOT NULL,
  description varchar NOT NULL
);

CREATE TABLE voting_form_fields (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id) ON DELETE cascade,
  question varchar NOT NULL,
  order_index int NOT NULL,
  type voting_form_field_type NOT NULL,
  slider_min_value int,
  slider_max_value int,
  is_required bool NOT NULL,
  scope voting_form_field_scope NOT NULL
);

CREATE TABLE contests (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  organizer_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  organizer_full_name varchar NOT NULL,
  name varchar NOT NULL,
  description varchar NOT NULL,
  date_time timestamptz NOT NULL,
  works_submission_start timestamptz NOT NULL,
  works_submission_end timestamptz NOT NULL,
  place_id uuid NOT NULL UNIQUE REFERENCES places (id),
  images_urls text[] NOT NULL,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('contests', 'token', 14)
);

CREATE TABLE participant_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('participant_invitations', 'token', 14),
  email varchar NOT NULL
);

CREATE TABLE juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  voting_form_id uuid NOT NULL UNIQUE REFERENCES voting_forms (id),
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('juries', 'token', 14),
  name varchar NOT NULL,
  type jury_type NOT NULL,
  UNIQUE (contest_id, name)
);

CREATE TABLE juror_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('juror_invitations', 'token', 14),
  email varchar NOT NULL
);

CREATE TABLE participations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  participant_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email varchar NOT NULL,
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (contest_id, participant_id)
);

CREATE TABLE works (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  participation_id uuid NOT NULL UNIQUE REFERENCES participations (id) ON DELETE cascade,
  participant_full_name varchar NOT NULL,
  name varchar NOT NULL,
  description varchar NOT NULL,
  images_urls text[] NOT NULL
);

CREATE TABLE jurations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  juror_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email varchar NOT NULL,
  UNIQUE (jury_id, juror_id)
);

CREATE TABLE voting_sessions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name varchar NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  is_geo_restricted bool NOT NULL,
  geo_res_place_id uuid UNIQUE REFERENCES places (id),
  geo_res_radius int,
  session_status voting_session_status NOT NULL
);

CREATE TABLE voting_session_participations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  participation_id uuid REFERENCES participations (id) ON DELETE SET NULL,
  order_index int NOT NULL,
  UNIQUE (voting_session_id, participation_id),
  -- snapshot data
  participant_full_name varchar NOT NULL,
  work_name varchar NOT NULL,
  work_description varchar NOT NULL,
  work_images_urls text[] NOT NULL
);

CREATE TABLE voting_session_juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  jury_id uuid REFERENCES juries (id) ON DELETE SET NULL,
  -- snapshot data
  jury_name varchar NOT NULL,
  voting_form_id uuid NOT NULL,
  token varchar(14) NOT NULL
);

CREATE TABLE voting_session_jurations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_jury_id uuid NOT NULL REFERENCES voting_session_juries (id) ON DELETE cascade,
  juration_id uuid REFERENCES jurations (id) ON DELETE SET NULL,
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (voting_session_id, juration_id),
  -- snapshot data
  juror_full_name varchar NOT NULL
);

CREATE TABLE voting_session_exclusions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (voting_session_juration_id, voting_session_participation_id)
);

CREATE TABLE simple_jurors (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name varchar NOT NULL
);

CREATE TABLE voting_session_simple_jurors (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_jury_id uuid NOT NULL REFERENCES voting_session_juries (id) ON DELETE cascade,
  simple_juror_id uuid NOT NULL REFERENCES simple_jurors (id),
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (voting_session_id, simple_juror_id)
);

-- NUOVA TABELLA: Rappresenta l'evento di sottomissione di un form da parte di un giurato.
-- MODIFICATA per essere flessibile e accettare sia giurati nominati che semplici.
CREATE TABLE voting_form_submissions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  -- A quale sessione di voto appartiene questa sottomissione.
  voting_session_id uuid NOT NULL REFERENCES voting_sessions(id) ON DELETE CASCADE,

  -- Chi ha sottomesso il form? Solo una di queste due colonne sarà valorizzata.
  voting_session_juration_id uuid REFERENCES voting_session_jurations(id) ON DELETE CASCADE,
  voting_session_simple_juror_id uuid REFERENCES voting_session_simple_jurors(id) ON DELETE CASCADE,

  -- Vincolo per assicurare che solo una delle due colonne FK sia popolata.
  CONSTRAINT chk_one_juror_type CHECK (
    (voting_session_juration_id IS NOT NULL AND voting_session_simple_juror_id IS NULL) OR
    (voting_session_juration_id IS NULL AND voting_session_simple_juror_id IS NOT NULL)
  ),

  -- Vincolo di unicità per evitare sottomissioni multiple.
  UNIQUE(voting_session_id, voting_session_juration_id),
  UNIQUE(voting_session_id, voting_session_simple_juror_id)
);

-- NUOVA TABELLA: Contiene i valori effettivi per ogni campo della sottomissione.
-- QUESTA TABELLA NON CAMBIA, il che dimostra la potenza di questo design.
CREATE TABLE voting_form_submission_values (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  -- A quale sottomissione appartiene questo valore.
  form_submission_id uuid NOT NULL REFERENCES voting_form_submissions(id) ON DELETE CASCADE,
  -- A quale campo del form si riferisce questo valore.
  form_field_id uuid NOT NULL REFERENCES voting_form_fields(id) ON DELETE CASCADE,
  -- Il valore inserito dall'utente.
  value text NOT NULL,
  -- Se il campo è di scope 'participant', a quale partecipante si riferisce?
  -- Se lo scope è 'header' o 'footer', questo campo sarà NULL.
  voting_session_participation_id uuid REFERENCES voting_session_participations(id) ON DELETE CASCADE,
  -- Evita che un giurato possa dare due voti per lo stesso campo e lo stesso partecipante.
  UNIQUE(form_submission_id, form_field_id, voting_session_participation_id)
);

--CREATE TABLE juror_votings (
--  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
--  created_at timestamptz NOT NULL DEFAULT now(),
--  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
--  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
--  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
--  UNIQUE (voting_session_juration_id, voting_session_participation_id)
--);
--
--CREATE TABLE juror_votes (
--  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
--  created_at timestamptz NOT NULL DEFAULT now(),
--  juror_voting_id uuid NOT NULL REFERENCES juror_votings (id) ON DELETE cascade,
--  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
--  value varchar NOT NULL,
--  UNIQUE (juror_voting_id, voting_form_field_id)
--);

--CREATE TABLE simple_juror_votings (
--  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
--  created_at timestamptz NOT NULL DEFAULT now(),
--  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
--  voting_session_simple_juror_id uuid NOT NULL REFERENCES voting_session_simple_jurors (id),
--  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
--  UNIQUE (voting_session_simple_juror_id, voting_session_participation_id)
--);
--
--CREATE TABLE simple_juror_votes (
--  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
--  created_at timestamptz NOT NULL DEFAULT now(),
--  simple_juror_voting_id uuid NOT NULL REFERENCES simple_juror_votings (id) ON DELETE cascade,
--  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
--  value varchar NOT NULL,
--  UNIQUE (simple_juror_voting_id, voting_form_field_id)
--);