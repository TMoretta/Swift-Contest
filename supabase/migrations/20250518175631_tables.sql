CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id),
  created_at timestamptz NOT NULL,
  full_name varchar(30) NOT NULL,
  pref_theme app_theme NOT NULL,
  pref_contest_role contest_role NOT NULL,
  is_deleted bool NOT NULL
);

CREATE TABLE places (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  address varchar(150) NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE voting_forms (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL
);

CREATE TABLE contests (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  organizer_id uuid NOT NULL REFERENCES profiles (id),
  name varchar(30) NOT NULL,
  description varchar(200) NOT NULL,
  date_time timestamptz NOT NULL,
  works_submission_start timestamptz NOT NULL,
  works_submission_end timestamptz NOT NULL,
  place_id uuid NOT NULL REFERENCES places (id),
  contest_status contest_status NOT NULL,
  images_urls TEXT[] NOT NULL,
  token varchar(14) NOT NULL UNIQUE,
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id),
  is_deleted bool NOT NULL
);

CREATE TABLE invitations (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id),
  token varchar(14) NOT NULL UNIQUE,
  email varchar NOT NULL,
  member_role member_role NOT NULL
);

CREATE TABLE participations (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id),
  participant_id uuid NOT NULL REFERENCES profiles (id),
  participant_status participant_status NOT NULL,
  has_submitted bool NOT NULL,
  UNIQUE (contest_id, participant_id)
);

CREATE TABLE works (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  participation_id uuid NOT NULL REFERENCES participations (id),
  name varchar(20) NOT NULL,
  description varchar(200) NOT NULL,
  images_urls text[] NOT NULL
);

CREATE TABLE jurations (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id),
  juror_id uuid NOT NULL REFERENCES profiles (id),
  juror_status juror_status NOT NULL,
  UNIQUE (contest_id, juror_id)
);

CREATE TABLE voting_form_fields (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id),
  name varchar(20) NOT NULL,
  order_index int NOT NULL,
  min_value int4,
  max_value int4
);

CREATE TABLE voting_sessions (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  name varchar NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id),
  are_simple_jurors_allowed bool NOT NULL,
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id),
  work_timer int NOT NULL,
  intermission_timer int NOT NULL,
  review_timer int NOT NULL,
  token varchar(14) NOT NULL UNIQUE,
  is_geo_restricted bool NOT NULL,
  geo_restriction_place_id uuid REFERENCES places (id),
  geo_restriction_radius int,
  session_status voting_session_status NOT NULL,
  current_participant_index int,
  current_step_deadline timestamptz
);

--CREATE TABLE voting_session_procedures (
--  id uuid PRIMARY KEY,
--  created_at timestamptz NOT NULL,
--  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id),
--  current_step voting_session_procedure_step,
--  current_participant_index int,
--  current_step_deadline timestamptz
--);

CREATE TABLE voting_session_participations (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id),
  participation_id uuid NOT NULL REFERENCES participations (id),
  order_index int NOT NULL,
  UNIQUE (voting_session_id, participation_id)
);

CREATE TABLE voting_session_jurations (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id),
  juration_id uuid NOT NULL REFERENCES jurations (id),
  has_submitted bool NOT NULL,
  UNIQUE (voting_session_id, juration_id)
);

CREATE TABLE voting_session_exclusions (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id)
);

CREATE TABLE juror_votings (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_juration_id uuid NOT NULL REFERENCES voting_session_jurations (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (
    voting_session_juration_id,
    voting_session_participation_id
  )
);

CREATE TABLE juror_votes (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  juror_voting_id uuid NOT NULL REFERENCES juror_votings (id),
  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
  value int NOT NULL,
  UNIQUE (juror_voting_id, voting_form_field_id)
);

CREATE TABLE simple_jurors (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  full_name varchar NOT NULL
);

CREATE TABLE voting_session_simple_jurors (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id),
  simple_juror_id uuid NOT NULL REFERENCES simple_jurors (id),
  has_submitted bool NOT NULL
);

CREATE TABLE simple_juror_votings (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  voting_session_simple_juror_id uuid NOT NULL REFERENCES voting_session_simple_jurors (id),
  voting_session_participation_id uuid NOT NULL REFERENCES voting_session_participations (id),
  UNIQUE (
    voting_session_simple_juror_id,
    voting_session_participation_id
  )
);

CREATE TABLE simple_juror_votes (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL,
  simple_juror_voting_id uuid NOT NULL REFERENCES simple_juror_votings (id),
  voting_form_field_id uuid NOT NULL REFERENCES voting_form_fields (id),
  value int NOT NULL,
  UNIQUE (simple_juror_voting_id, voting_form_field_id)
);