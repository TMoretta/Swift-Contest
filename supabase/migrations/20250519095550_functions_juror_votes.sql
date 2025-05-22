-- CREATE JUROR VOTE
CREATE OR REPLACE FUNCTION public.create_juror_vote (
  p_id uuid,
  p_created_at timestamptz,
  p_juror_voting_id uuid,
  p_voting_form_field_id uuid,
  p_value varchar(150)
)
RETURNS SETOF public.juror_votes AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.juror_votes (
      id,
      created_at,
      juror_voting_id,
      voting_form_field_id,
      value
    )
    VALUES (
      p_id,
      p_created_at,
      p_juror_voting_id,
      p_voting_form_field_id,
      p_value
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.update_juror_vote (
  p_id uuid,
  p_created_at timestamptz,
  p_juror_voting_id uuid,
  p_voting_form_field_id uuid,
  p_value varchar(150)
)
RETURNS SETOF public.juror_votes AS $$
BEGIN
  RETURN QUERY
    UPDATE public.juror_votes
    SET
      created_at = p_created_at,
      juror_voting_id = p_juror_voting_id,
      voting_form_field_id = p_voting_form_field_id,
      value = p_value
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.delete_juror_vote_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.juror_votes
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTE BY ID
CREATE OR REPLACE FUNCTION public.get_juror_vote_by_id(
  p_id uuid
)
RETURNS SETOF public.juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votes
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET JUROR VOTES BY JUROR VOTING ID
CREATE OR REPLACE FUNCTION public.get_juror_votes_by_juror_voting_id(
  p_juror_voting_id uuid
)
RETURNS SETOF public.juror_votes AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.juror_votes
    WHERE juror_voting_id = p_juror_voting_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;