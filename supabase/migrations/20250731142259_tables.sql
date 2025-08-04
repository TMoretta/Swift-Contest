CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE cascade,
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name text NOT NULL,
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
  address text NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE voting_forms (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  description text NOT NULL
);

CREATE TABLE voting_form_fields (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id) ON DELETE cascade,
  question text NOT NULL,
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
  organizer_full_name text NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  date_time timestamptz NOT NULL,
  works_submission_start timestamptz NOT NULL,
  works_submission_end timestamptz NOT NULL,
  place_id uuid NOT NULL UNIQUE REFERENCES places (id),
  images_urls text[] NOT NULL
);

CREATE TABLE participant_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  token uuid NOT NULL UNIQUE DEFAULT extensions.uuid_generate_v4(),
  email text NOT NULL
);

CREATE TABLE juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  voting_form_id uuid NOT NULL UNIQUE REFERENCES voting_forms (id),
  token uuid NOT NULL UNIQUE DEFAULT extensions.uuid_generate_v4(),
  name text NOT NULL,
  type jury_type NOT NULL,
  UNIQUE (contest_id, name)
);

CREATE TABLE juror_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  token uuid NOT NULL UNIQUE DEFAULT extensions.uuid_generate_v4(),
  email text NOT NULL
);

CREATE TABLE participations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  participant_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email text NOT NULL,
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (contest_id, participant_id)
);

CREATE TABLE works (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  participation_id uuid NOT NULL UNIQUE REFERENCES participations (id) ON DELETE cascade,
  participant_full_name text NOT NULL,
  name text NOT NULL,
  description text NOT NULL,
  images_urls text[] NOT NULL
);

CREATE TABLE jurations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  juror_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email text NOT NULL,
  UNIQUE (jury_id, juror_id)
);

CREATE TABLE voting_sessions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name text NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  is_geo_restricted bool NOT NULL,
  geo_res_place_id uuid UNIQUE REFERENCES places (id),
  geo_res_radius int,
  session_status voting_session_status NOT NULL
);

CREATE TABLE voting_session_participants (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  participation_id uuid REFERENCES participations (id) ON DELETE SET NULL,
  order_index int NOT NULL,
  UNIQUE (voting_session_id, participation_id),
  -- snapshot data
  participant_full_name text NOT NULL,
  work_name text NOT NULL,
  work_description text NOT NULL,
  work_images_urls text[] NOT NULL
);

CREATE TABLE voting_session_juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  jury_id uuid REFERENCES juries (id) ON DELETE SET NULL,
  -- snapshot data
  jury_name text NOT NULL,
  jury_type jury_type NOT NULL,
  voting_form_id uuid NOT NULL,
  jury_token uuid NOT NULL,
  UNIQUE (voting_session_id, jury_token)
);

CREATE TABLE voting_session_jurors (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_jury_id uuid NOT NULL REFERENCES voting_session_juries (id) ON DELETE cascade,
  juration_id uuid REFERENCES jurations (id) ON DELETE SET NULL,
  juror_id uuid REFERENCES profiles (id) ON DELETE SET NULL,
  has_submitted bool NOT NULL DEFAULT false,
  -- snapshot data
  juror_full_name text NOT NULL,
  UNIQUE (voting_session_jury_id, juror_id)
);

CREATE TABLE voting_session_exclusions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_juror_id uuid NOT NULL REFERENCES voting_session_jurors (id) ON DELETE cascade,
  voting_session_participant_id uuid NOT NULL REFERENCES voting_session_participants (id) ON DELETE cascade,
  UNIQUE (voting_session_juror_id, voting_session_participant_id)
);

CREATE TABLE voting_form_submissions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions(id) ON DELETE CASCADE,
  voting_session_juror_id uuid UNIQUE REFERENCES voting_session_jurors(id) ON DELETE CASCADE
);

CREATE TABLE voting_form_submission_values (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  voting_form_submission_id uuid NOT NULL REFERENCES voting_form_submissions(id) ON DELETE CASCADE,
  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields(id) ON DELETE CASCADE,
  value text NOT NULL,
  -- Se il campo è di scope 'participant', a quale partecipante si riferisce?
  -- Se lo scope è 'header' o 'footer', questo campo sarà NULL.
  voting_session_participant_id uuid REFERENCES voting_session_participants(id) ON DELETE CASCADE,
  -- Evita che un giurato possa dare due voti per lo stesso campo e lo stesso partecipante.
  UNIQUE(voting_form_submission_id, voting_form_field_id, voting_session_participant_id)
);

CREATE TABLE public.contest_rankings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES public.contests(id) ON DELETE CASCADE,
  name text NOT NULL,
  file_path text NOT NULL UNIQUE,
  published_at timestamptz NOT NULL DEFAULT now()
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
--  value text NOT NULL,
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
--  value text NOT NULL,
--  UNIQUE (simple_juror_voting_id, voting_form_field_id)
--);