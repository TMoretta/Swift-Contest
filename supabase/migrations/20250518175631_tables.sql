CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE cascade,
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name varchar NOT NULL,
  pref_role contest_role NOT NULL DEFAULT 'organizer'
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  account_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  title text NOT NULL,
  body text NOT NULL,
  is_read bool NOT NULL DEFAULT false
);

CREATE TABLE places (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  address varchar NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE voting_forms (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE contests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
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
--  deleted_at timestamptz
);

CREATE TABLE participant_invitations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('participant_invitations', 'token', 14),
  email varchar NOT NULL
);

CREATE TABLE juries (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  voting_form_id uuid NOT NULL UNIQUE REFERENCES voting_forms (id),
  name varchar NOT NULL
);

CREATE TABLE juror_invitations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('juror_invitations', 'token', 14),
  email varchar NOT NULL
);

CREATE TABLE participations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  participant_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
--  participant_status participant_status NOT NULL DEFAULT 'joined',
  invitation_email varchar NOT NULL,
  has_submitted bool NOT NULL DEFAULT false
--  deleted_at bool
--  UNIQUE (contest_id, participant_id)
);

CREATE TABLE works (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  participation_id uuid NOT NULL UNIQUE REFERENCES participations (id) ON DELETE cascade,
  participant_full_name varchar NOT NULL,
  name varchar NOT NULL,
  description varchar NOT NULL,
  images_urls text[] NOT NULL,
  file_url text NOT NULL
);

CREATE TABLE jurations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  juror_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
--  juror_status juror_status NOT NULL DEFAULT 'joined',
  invitation_email varchar NOT NULL
--  deleted_at bool
--  UNIQUE (jury_id, juror_id)
);

CREATE TABLE voting_form_fields (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id) ON DELETE cascade,
  name varchar NOT NULL,
  order_index int NOT NULL,
  min_value numeric(7,2) NOT NULL,
  max_value numeric(7,2) NOT NULL
);

CREATE TABLE voting_sessions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name varchar NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  are_simple_jurors_allowed bool NOT NULL,
  voting_form_id uuid NOT NULL UNIQUE REFERENCES voting_forms (id),
  work_timer int NOT NULL,
  intermission_timer int NOT NULL,
  review_timer int NOT NULL,
  token varchar(14) NOT NULL UNIQUE DEFAULT gen_unique_token('voting_sessions', 'token', 14),
  is_geo_restricted bool NOT NULL,
  geo_res_place_id uuid UNIQUE REFERENCES places (id),
  geo_res_radius int,
  session_status voting_session_status NOT NULL,
  current_participant_index int,
  current_step_deadline timestamptz
);

CREATE TABLE voting_session_participations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  participation_snapshot_id uuid NOT NULL REFERENCES participations (id), --CREATE ALSO WORK TO LINK WITH THIS SNAPSHOT
--  participation_id uuid REFERENCES participations (id),
  order_index int NOT NULL,
  is_excluded bool NOT NULL DEFAULT false,
  UNIQUE (voting_session_id, participation_snapshot_id)
);

CREATE TABLE voting_session_jurations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  juration_snapshot_id uuid NOT NULL REFERENCES jurations (id),
--  juration_id uuid REFERENCES jurations (id),
  has_submitted bool NOT NULL DEFAULT false,
  is_excluded bool NOT NULL DEFAULT false,
  UNIQUE (voting_session_id, juration_snapshot_id)
);

CREATE TABLE voting_session_exclusions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (voting_session_juration_id, voting_session_participation_id)
);

CREATE TABLE juror_votings (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (voting_session_juration_id, voting_session_participation_id)
);

CREATE TABLE juror_votes (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  juror_voting_id uuid NOT NULL REFERENCES juror_votings (id) ON DELETE cascade,
  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
  value numeric(7,2) NOT NULL,
  UNIQUE (juror_voting_id, voting_form_field_id)
);

CREATE TABLE simple_jurors (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name varchar NOT NULL
);

CREATE TABLE voting_session_simple_jurors (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  simple_juror_id uuid NOT NULL REFERENCES simple_jurors (id),
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (voting_session_id, simple_juror_id)
);

CREATE TABLE simple_juror_votings (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_simple_juror_id uuid NOT NULL REFERENCES voting_session_simple_jurors (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (voting_session_simple_juror_id, voting_session_participation_id)
);

CREATE TABLE simple_juror_votes (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  simple_juror_voting_id uuid NOT NULL REFERENCES simple_juror_votings (id) ON DELETE cascade,
  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
  value numeric(7,2) NOT NULL,
  UNIQUE (simple_juror_voting_id, voting_form_field_id)
);