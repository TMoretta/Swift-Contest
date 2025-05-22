-- CREATE SIMPLE JUROR VOTE
CREATE OR REPLACE FUNCTION public.create_simple_juror_vote (
  p_id uuid,
  p_created_at timestamptz,
  p_simple_juror_voting_id uuid,
  p_voting_form_field_id uuid,
  p_value character varying(150)
)
RETURNS SETOF public.simple_juror_votes AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.simple_juror_votes (
      id,
      created_at,
      simple_juror_voting_id,
      voting_form_field_id,
      value
    )
    VALUES (
      p_id,
      p_created_at,
      p_simple_juror_voting_id,
      p_voting_form_field_id,
      p_value
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.update_simple_juror_vote (
  p_id uuid,
  p_created_at timestamptz,
  p_simple_juror_voting_id uuid,
  p_voting_form_field_id uuid,
  p_value character varying(150)
)
RETURNS SETOF public.simple_juror_votes AS $$
BEGIN
  RETURN QUERY
    UPDATE public.simple_juror_votes
    SET
      created_at = p_created_at,
      simple_juror_voting_id = p_simple_juror_voting_id,
      voting_form_field_id = p_voting_form_field_id,
      value = p_value
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.delete_simple_juror_vote_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.simple_juror_votes
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.get_simple_juror_vote_by_id(
  p_id uuid
)
RETURNS SETOF public.simple_juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.simple_juror_votes
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET SIMPLE JUROR VOTES BY SIMPLE JUROR VOTING ID
CREATE OR REPLACE FUNCTION public.get_simple_juror_votes_by_simple_juror_voting_id(
  p_simple_juror_voting_id uuid
)
RETURNS SETOF public.simple_juror_votes AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.simple_juror_votes
  WHERE simple_juror_voting_id = p_simple_juror_voting_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;