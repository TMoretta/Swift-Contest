-- CREATE VOTING SESSION
CREATE OR REPLACE FUNCTION public.create_voting_session (
  p_id uuid,
  p_created_at timestamptz,
  p_name character varying,
  p_contest_id uuid,
  p_are_simple_jurors_allowed boolean,
  p_voting_form_id uuid,
  p_work_timer integer,
  p_intermission_timer integer,
  p_review_timer integer,
  p_is_ended boolean,
  p_token character varying(8),
  p_is_geo_restricted boolean,
  p_geo_restriction_place_id uuid,
  p_geo_restriction_radius integer
)
RETURNS SETOF public.voting_sessions AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.voting_sessions (
      id,
      created_at,
      name,
      contest_id,
      are_simple_jurors_allowed,
      voting_form_id,
      work_timer,
      intermission_timer,
      review_timer,
      is_ended,
      token,
      is_geo_restricted,
      geo_restriction_place_id,
      geo_restriction_radius
    )
    VALUES (
      p_id,
      p_created_at,
      p_name,
      p_contest_id,
      p_are_simple_jurors_allowed,
      p_voting_form_id,
      p_work_timer,
      p_intermission_timer,
      p_review_timer,
      p_is_ended,
      p_token,
      p_is_geo_restricted,
      p_geo_restriction_place_id,
      p_geo_restriction_radius
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION public.update_voting_session (
  p_id uuid,
  p_created_at timestamptz,
  p_name character varying,
  p_contest_id uuid,
  p_are_simple_jurors_allowed boolean,
  p_voting_form_id uuid,
  p_work_timer integer,
  p_intermission_timer integer,
  p_review_timer integer,
  p_is_ended boolean,
  p_token character varying(8),
  p_is_geo_restricted boolean,
  p_geo_restriction_place_id uuid,
  p_geo_restriction_radius integer
)
RETURNS SETOF public.voting_sessions AS $$
BEGIN
  RETURN QUERY
    UPDATE public.voting_sessions
    SET
      created_at = p_created_at,
      name = p_name,
      contest_id = p_contest_id,
      are_simple_jurors_allowed = p_are_simple_jurors_allowed,
      voting_form_id = p_voting_form_id,
      work_timer = p_work_timer,
      intermission_timer = p_intermission_timer,
      review_timer = p_review_timer,
      is_ended = p_is_ended,
      token = p_token,
      is_geo_restricted = p_is_geo_restricted,
      geo_restriction_place_id = p_geo_restriction_place_id,
      geo_restriction_radius = p_geo_restriction_radius
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION public.delete_voting_session_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.voting_sessions
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION BY ID
CREATE OR REPLACE FUNCTION public.get_voting_session_by_id(
  p_id uuid
)
RETURNS SETOF public.voting_sessions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_sessions
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION public.get_voting_sessions_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF public.voting_sessions AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.voting_sessions
  WHERE contest_id = p_contest_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION BY TOKEN
CREATE OR REPLACE FUNCTION public.get_voting_session_by_token(
  p_token character varying(8)
)
RETURNS SETOF public.voting_sessions AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_sessions
    WHERE token = p_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;