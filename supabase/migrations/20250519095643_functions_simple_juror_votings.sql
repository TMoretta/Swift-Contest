-- CREATE SIMPLE JUROR VOTING
CREATE OR REPLACE FUNCTION public.create_simple_juror_voting (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_voting_session_simple_juror_id uuid,
  p_voting_session_participant_id uuid
)
RETURNS SETOF public.simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.simple_juror_votings (
      id,
      created_at,
      voting_session_id,
      voting_session_simple_juror_id,
      voting_session_participant_id
    )
    VALUES (
      p_id,
      p_created_at,
      p_voting_session_id,
      p_voting_session_simple_juror_id,
      p_voting_session_participant_id
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.update_simple_juror_voting (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_voting_session_simple_juror_id uuid,
  p_voting_session_participant_id uuid
)
RETURNS SETOF public.simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    UPDATE public.simple_juror_votings
    SET
      created_at = p_created_at,
      voting_session_id = p_voting_session_id,
      voting_session_simple_juror_id = p_voting_session_simple_juror_id,
      voting_session_participant_id = p_voting_session_participant_id
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.delete_simple_juror_voting_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.simple_juror_votings
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTING BY ID
CREATE OR REPLACE FUNCTION public.get_simple_juror_voting_by_id(
  p_id uuid
)
RETURNS SETOF public.simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.simple_juror_votings
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTINGS BY VOTING SESSION SIMPLE JUROR ID
CREATE OR REPLACE FUNCTION public.get_simple_juror_votings_by_voting_session_simple_juror_id(
  p_voting_session_simple_juror_id uuid
)
RETURNS SETOF public.simple_juror_votings AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.simple_juror_votings
  WHERE voting_session_simple_juror_id = p_voting_session_simple_juror_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING BY VOTING SESSION SIMPLE JUROR ID AND VOTING SESSION PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_voting_by_voting_session_simple_juror_id_and_voting_session_participant_id(
  p_voting_session_simple_juror_id uuid,
  p_voting_session_participant_id uuid
)
RETURNS SETOF public.simple_juror_votings AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.simple_juror_votings
    WHERE voting_session_simple_juror_id = p_voting_session_simple_juror_id
      AND voting_session_participant_id = p_voting_session_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;