-- CREATE VOTING FORM
CREATE OR REPLACE FUNCTION public.create_voting_form (
  p_id uuid,
  p_created_at timestamptz
)
RETURNS SETOF public.voting_forms AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.voting_forms (
      id,
      created_at
    )
    VALUES (
      p_id,
      p_created_at
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING FORM BY ID
CREATE OR REPLACE FUNCTION public.update_voting_form (
  p_id uuid,
  p_created_at timestamptz
)
RETURNS SETOF public.voting_forms AS $$
BEGIN
  RETURN QUERY
    UPDATE public.voting_forms
    SET
      created_at = p_created_at
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING FORM BY ID
CREATE OR REPLACE FUNCTION public.delete_voting_form_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.voting_forms
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM BY ID
CREATE OR REPLACE FUNCTION public.get_voting_form_by_id(
  p_id uuid
)
RETURNS SETOF public.voting_forms AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_forms
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;