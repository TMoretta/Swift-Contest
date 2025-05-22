-- CREATE VOTING FORM FIELD
CREATE OR REPLACE FUNCTION public.create_voting_form_field (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_form_id uuid,
  p_name character varying(20),
  p_order_index integer,
  p_min_value integer,
  p_max_value integer
)
RETURNS SETOF public.voting_form_fields AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.voting_form_fields (
      id,
      created_at,
      voting_form_id,
      name,
      order_index,
      min_value,
      max_value
    )
    VALUES (
      p_id,
      p_created_at,
      p_voting_form_id,
      p_name,
      p_order_index,
      p_min_value,
      p_max_value
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION public.update_voting_form_field (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_form_id uuid,
  p_name character varying(20),
  p_order_index integer,
  p_min_value integer,
  p_max_value integer
)
RETURNS SETOF public.voting_form_fields AS $$
BEGIN
  RETURN QUERY
    UPDATE public.voting_form_fields
    SET
      created_at = p_created_at,
      voting_form_id = p_voting_form_id,
      name = p_name,
      order_index = p_order_index,
      min_value = p_min_value,
      max_value = p_max_value
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION public.delete_voting_form_field_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.voting_form_fields
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION public.get_voting_form_field_by_id(
  p_id uuid
)
RETURNS SETOF public.voting_form_fields AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_form_fields
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM FIELDS BY VOTING FORM ID
CREATE OR REPLACE FUNCTION public.get_voting_form_fields_by_voting_form_id(
  p_voting_form_id uuid
)
RETURNS SETOF public.voting_form_fields AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.voting_form_fields
  WHERE voting_form_id = p_voting_form_id
  ORDER BY order_index; -- Added ORDER BY for consistency if needed
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;