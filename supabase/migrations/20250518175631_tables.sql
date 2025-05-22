CREATE TABLE public.profiles (
  id uuid PRIMARY KEY NOT NULL REFERENCES auth.users (id),
  created_at timestamptz NOT NULL,
  full_name varchar(30) NOT NULL,
  pref_theme app_theme NOT NULL,
  pref_contest_role contest_role NOT NULL,
  is_deleted bool NOT NULL
);

CREATE TABLE public.places (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  address varchar(150) NOT NULL,
  lat float NOT NULL,
  lon float NOT NULL
);

CREATE TABLE public.voting_forms (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL
);

CREATE TABLE public.contests (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  organizer_id uuid NOT NULL REFERENCES public.profiles (id),
  name varchar(30) NOT NULL,
  description varchar(200) NOT NULL,
  is_jurors_works_preview_enabled bool NOT NULL,
  date_time timestamptz NOT NULL,
  works_submission_from timestamptz NOT NULL,
  works_submission_to timestamptz NOT NULL,
  place_id uuid NOT NULL REFERENCES public.places (id),
  contest_status contest_status NOT NULL,
  images_urls TEXT[] NOT NULL,
  token varchar(8) NOT NULL UNIQUE,
  voting_form_id uuid NOT NULL REFERENCES public.voting_forms (id),
  is_deleted bool NOT NULL
);

CREATE TABLE public.invitations (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES public.contests (id),
  token varchar(8) NOT NULL UNIQUE,
  email varchar NOT NULL,
  member_role member_role NOT NULL
);

CREATE TABLE public.participations (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES public.contests (id),
  participant_id uuid NOT NULL REFERENCES public.profiles (id),
  participant_status participant_status NOT NULL,
  work_status work_status NOT NULL,
  UNIQUE (contest_id, participant_id)
);

CREATE TABLE public.works (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  participation_id uuid NOT NULL REFERENCES public.participations (id),
  name varchar(20) NOT NULL,
  description varchar(200) NOT NULL,
  images_urls TEXT[] NOT NULL
);

CREATE TABLE public.jurations (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  contest_id uuid NOT NULL REFERENCES public.contests (id),
  juror_id uuid NOT NULL REFERENCES public.profiles (id),
  juror_status juror_status NOT NULL,
  UNIQUE (contest_id, juror_id)
);

CREATE TABLE public.voting_form_fields (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_form_id uuid NOT NULL REFERENCES public.voting_forms (id),
  name varchar(20) NOT NULL,
  order_index int NOT NULL,
  -- field_type form_field_type NOT NULL,
  -- is_optional bool NOT NULL,
  min_value int4,
  max_value int4
);

CREATE TABLE public.voting_sessions (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  name varchar NOT NULL,
  contest_id uuid NOT NULL REFERENCES public.contests (id),
  are_simple_jurors_allowed bool NOT NULL,
  voting_form_id uuid NOT NULL REFERENCES public.voting_forms (id),
  work_timer int NOT NULL,
  intermission_timer int NOT NULL,
  review_timer int NOT NULL,
  is_ended bool NOT NULL,
  token varchar(8) NOT NULL,
  is_geo_restricted bool NOT NULL,
  geo_restriction_place_id uuid REFERENCES public.places (id),
  geo_restriction_radius int
);

CREATE TABLE public.voting_session_procedures (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  is_live boolean,
  current_step voting_session_procedure_step,
  current_participant_index int,
  current_step_deadline timestamptz
);

CREATE TABLE public.voting_session_participants (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  participant_id uuid NOT NULL REFERENCES public.profiles (id),
  order_index int NOT NULL,
  UNIQUE (voting_session_id, participant_id)
);

CREATE TABLE public.voting_session_jurors (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  juror_id uuid NOT NULL REFERENCES public.profiles (id),
  has_submitted bool NOT NULL,
  UNIQUE (voting_session_id, juror_id)
);

CREATE TABLE public.juror_votings (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  voting_session_juror_id uuid NOT NULL REFERENCES public.voting_session_jurors (id),
  voting_session_participant_id uuid NOT NULL REFERENCES public.voting_session_participants (id),
  is_excluded bool NOT NULL,
  UNIQUE (
    voting_session_juror_id,
    voting_session_participant_id
  )
);

CREATE TABLE public.juror_votes (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  juror_voting_id uuid NOT NULL REFERENCES public.juror_votings (id),
  voting_form_field_id uuid NOT NULL REFERENCES public.voting_form_fields (id),
  value varchar(150) NOT NULL,
  UNIQUE (juror_voting_id, voting_form_field_id)
);

CREATE TABLE public.simple_jurors (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  full_name varchar NOT NULL
);

CREATE TABLE public.voting_session_simple_jurors (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  simple_juror_id uuid NOT NULL REFERENCES public.simple_jurors (id),
  has_submitted bool NOT NULL
);

CREATE TABLE public.simple_juror_votings (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  voting_session_id uuid NOT NULL REFERENCES public.voting_sessions (id),
  voting_session_simple_juror_id uuid NOT NULL REFERENCES public.voting_session_simple_jurors (id),
  voting_session_participant_id uuid NOT NULL REFERENCES public.voting_session_participants (id),
  UNIQUE (
    voting_session_simple_juror_id,
    voting_session_participant_id
  )
);

CREATE TABLE public.simple_juror_votes (
  id uuid PRIMARY KEY NOT NULL,
  created_at timestamptz NOT NULL,
  simple_juror_voting_id uuid NOT NULL REFERENCES public.simple_juror_votings (id),
  voting_form_field_id uuid NOT NULL REFERENCES public.voting_form_fields (id),
  value varchar(150) NOT NULL,
  UNIQUE (simple_juror_voting_id, voting_form_field_id)
);