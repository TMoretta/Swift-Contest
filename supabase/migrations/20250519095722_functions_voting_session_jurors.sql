-- CREATE VOTING SESSION JUROR
CREATE OR REPLACE FUNCTION public.create_voting_session_juror (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_juror_id uuid,
  p_has_submitted boolean
)
RETURNS SETOF public.voting_session_jurors AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.voting_session_jurors (
      id,
      created_at,
      voting_session_id,
      juror_id,
      has_submitted
    )
    VALUES (
      p_id,
      p_created_at,
      p_voting_session_id,
      p_juror_id,
      p_has_submitted
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION JUROR BY ID
CREATE OR REPLACE FUNCTION public.update_voting_session_juror (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_juror_id uuid,
  p_has_submitted boolean
)
RETURNS SETOF public.voting_session_jurors AS $$
BEGIN
  RETURN QUERY
    UPDATE public.voting_session_jurors
    SET
      created_at = p_created_at,
      voting_session_id = p_voting_session_id,
      juror_id = p_juror_id,
      has_submitted = p_has_submitted
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION JUROR BY ID
CREATE OR REPLACE FUNCTION public.delete_voting_session_juror_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.voting_session_jurors
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JUROR BY ID
CREATE OR REPLACE FUNCTION public.get_voting_session_juror_by_id(
  p_id uuid
)
RETURNS SETOF public.voting_session_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_session_jurors
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JUROR BY VOTING SESSION ID AND JUROR ID
CREATE OR REPLACE FUNCTION public.get_voting_session_juror_by_voting_session_id_and_juror_id(
  p_voting_session_id uuid,
  p_juror_id uuid
)
RETURNS SETOF public.voting_session_jurors AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_session_jurors
    WHERE voting_session_id = p_voting_session_id AND juror_id = p_juror_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION JURORS BY VOTING SESSION ID
CREATE OR REPLACE FUNCTION public.get_voting_session_jurors_by_voting_session_id(
  p_voting_session_id uuid
)
RETURNS SETOF public.voting_session_jurors AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.voting_session_jurors
  WHERE voting_session_id = p_voting_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;