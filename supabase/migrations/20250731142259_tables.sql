CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE cascade,
  created_at timestamptz NOT NULL DEFAULT now(),
  full_name varchar(70) NOT NULL,
  CHECK (char_length(full_name) >= 3),
  pref_role contest_role NOT NULL DEFAULT 'organizer'
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  account_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  title varchar(50) NOT NULL,
  body varchar(1000) NOT NULL,
  is_read bool NOT NULL DEFAULT false
);

CREATE TABLE places (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  address varchar(255) NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE voting_forms (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name varchar(50) NOT NULL,
  description varchar(1000) NOT NULL
);

CREATE TABLE voting_form_fields (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_form_id uuid NOT NULL REFERENCES voting_forms (id) ON DELETE cascade,
  question varchar(255) NOT NULL,
  order_index int NOT NULL,
  type voting_form_field_type NOT NULL,
  slider_min_value int,
  slider_max_value int,
  is_required bool NOT NULL,
  scope voting_form_field_scope NOT NULL,
  CHECK (char_length(question) >= 5),
  CHECK (
    (type = 'textual' AND slider_min_value IS NULL AND slider_max_value IS NULL)
    OR
    (type = 'slider' AND slider_min_value IS NOT NULL AND slider_max_value IS NOT NULL AND slider_min_value < slider_max_value)
  )
);

CREATE TABLE contests (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  organizer_id uuid NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
  name varchar(50) NOT NULL,
  description varchar(1000) NOT NULL,
  date_time timestamptz NOT NULL,
  works_submission_start timestamptz NOT NULL,
  works_submission_end timestamptz NOT NULL,
  place_id uuid NOT NULL UNIQUE REFERENCES places (id),
  images_paths text[] NOT NULL
);

CREATE TABLE participant_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT public.gen_unique_token('participant_invitations', 'token', 14),
  email varchar(254) NOT NULL
);

CREATE TABLE juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  voting_form_id uuid NOT NULL UNIQUE REFERENCES voting_forms (id),
  token varchar(14) NOT NULL UNIQUE DEFAULT public.gen_unique_token('juries', 'token', 14),
  name varchar(50) NOT NULL,
  type jury_type NOT NULL,
  UNIQUE (contest_id, name)
);

CREATE TABLE juror_invitations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  token varchar(14) NOT NULL UNIQUE DEFAULT public.gen_unique_token('juror_invitations', 'token', 14),
  email varchar(254) NOT NULL
);

CREATE TABLE participations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  participant_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email varchar(254) NOT NULL,
  has_submitted bool NOT NULL DEFAULT false,
  UNIQUE (contest_id, participant_id)
);

CREATE TABLE works (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  participation_id uuid NOT NULL UNIQUE REFERENCES participations (id) ON DELETE cascade,
  name varchar(50) NOT NULL,
  description varchar(1000) NOT NULL,
  images_paths text[] NOT NULL
);

CREATE TABLE jurations (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  jury_id uuid NOT NULL REFERENCES juries (id) ON DELETE cascade,
  juror_id uuid NOT NULL REFERENCES profiles (id) ON DELETE cascade,
  invitation_email varchar(254) NOT NULL,
  UNIQUE (jury_id, juror_id)
);

CREATE TABLE voting_sessions (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  name varchar(50) NOT NULL,
  contest_id uuid NOT NULL REFERENCES contests (id) ON DELETE cascade,
  is_geo_restricted bool NOT NULL,
  geo_res_place_id uuid UNIQUE REFERENCES places (id),
  geo_res_radius int,
  session_status voting_session_status NOT NULL,
  CHECK (
    (is_geo_restricted = false AND geo_res_place_id IS NULL AND geo_res_radius IS NULL)
    OR
    (is_geo_restricted = true AND geo_res_place_id IS NOT NULL AND geo_res_radius IS NOT NULL AND geo_res_radius > 0)
  )
);

CREATE TABLE voting_session_participants (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  participation_id uuid REFERENCES participations (id) ON DELETE SET NULL,
  order_index int NOT NULL,
  UNIQUE (voting_session_id, participation_id),
  -- snapshot data 
  participant_full_name varchar(70) NOT NULL,
  work_name varchar(50) NOT NULL,
  work_description varchar(1000) NOT NULL,
  work_images_paths text[] NOT NULL
);

CREATE TABLE voting_session_juries (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  jury_id uuid REFERENCES juries (id) ON DELETE SET NULL,
  -- snapshot data
  jury_name varchar(50) NOT NULL,
  jury_type jury_type NOT NULL,
  voting_form_id uuid NOT NULL,
  jury_token varchar(14) NOT NULL,
  UNIQUE (voting_session_id, jury_token)
);

CREATE TABLE voting_session_jurors (
  id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  created_at timestamptz NOT NULL DEFAULT now(),
  voting_session_id uuid NOT NULL REFERENCES voting_sessions (id) ON DELETE cascade,
  voting_session_jury_id uuid NOT NULL REFERENCES voting_session_juries (id) ON DELETE cascade,
  juration_id uuid REFERENCES jurations (id) ON DELETE SET NULL, -- entrambi se è un juror che fa parte del contest
  juror_id uuid REFERENCES profiles (id) ON DELETE SET NULL, -- solo questo se è un simple juror
  has_submitted bool NOT NULL DEFAULT false,
  -- snapshot data
  juror_full_name varchar(70) NOT NULL,
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
  file_path text NOT NULL UNIQUE
);
