-- CREATE JUROR VOTING
CREATE OR REPLACE FUNCTION public.create_juror_voting (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_voting_session_juror_id uuid,
  p_voting_session_participant_id uuid,
  p_is_excluded boolean
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.juror_votings (
      id,
      created_at,
      voting_session_id,
      voting_session_juror_id,
      voting_session_participant_id,
      is_excluded
    )
    VALUES (
      p_id,
      p_created_at,
      p_voting_session_id,
      p_voting_session_juror_id,
      p_voting_session_participant_id,
      p_is_excluded
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.update_juror_voting (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_voting_session_juror_id uuid,
  p_voting_session_participant_id uuid,
  p_is_excluded boolean
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    UPDATE public.juror_votings
    SET
      created_at = p_created_at,
      voting_session_id = p_voting_session_id,
      voting_session_juror_id = p_voting_session_juror_id,
      voting_session_participant_id = p_voting_session_participant_id,
      is_excluded = p_is_excluded
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.delete_juror_voting_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.juror_votings
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.get_juror_voting_by_id(
  p_id uuid
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votings
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTING BY VOTING SESSION JUROR ID AND VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_juror_voting_by_voting_session_juror_id_and_voting_session_participant_id(
  p_voting_session_juror_id uuid,
  p_voting_session_participant_id uuid
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votings
    WHERE voting_session_juror_id = p_voting_session_juror_id
      AND voting_session_participant_id = p_voting_session_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTINGS BY VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_juror_votings_by_voting_session_participant_id(
  p_voting_session_participant_id uuid
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votings
    WHERE voting_session_participant_id = p_voting_session_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTINGS BY VOTING SESSION JUROR ID
CREATE OR REPLACE FUNCTION public.get_juror_votings_by_voting_session_juror_id(
  p_voting_session_juror_id uuid
)
RETURNS SETOF public.juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votings
    WHERE voting_session_juror_id = p_voting_session_juror_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;