-- CREATE VOTING FORM FIELD
CREATE OR REPLACE FUNCTION create_voting_form_field (
  p_voting_form_field voting_form_fields
)
RETURNS voting_form_fields AS $$
DECLARE
  v_voting_form_field voting_form_fields;
BEGIN
  INSERT INTO voting_form_fields (
    id,
    created_at,
    voting_form_id,
    name,
    order_index,
    min_value,
    max_value
  )
  VALUES (
    p_voting_form_field.id,
    p_voting_form_field.created_at,
    p_voting_form_field.voting_form_id,
    p_voting_form_field.name,
    p_voting_form_field.order_index,
    p_voting_form_field.min_value,
    p_voting_form_field.max_value
  )
  RETURNING * INTO STRICT v_voting_form_field;

  RETURN v_voting_form_field;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting form field';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION update_voting_form_field (
  p_voting_form_field voting_form_fields
)
RETURNS voting_form_fields AS $$
DECLARE
  v_voting_form_field voting_form_fields;
BEGIN
  -- Verify if the voting form field exists
  IF NOT EXISTS (SELECT 1 FROM voting_form_fields WHERE id = p_voting_form_field.id) THEN
    RAISE EXCEPTION 'No voting form field found';
  END IF;

  UPDATE voting_form_fields
  SET
    voting_form_id = p_voting_form_field.voting_form_id,
    name = p_voting_form_field.name,
    order_index = p_voting_form_field.order_index,
    min_value = p_voting_form_field.min_value,
    max_value = p_voting_form_field.max_value
  WHERE id = p_voting_form_field.id
  RETURNING * INTO STRICT v_voting_form_field;

  RETURN v_voting_form_field;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the voting form field';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION delete_voting_form_field_by_id(
  p_id uuid
)
RETURNS voting_form_fields AS $$
DECLARE
  v_voting_form_field voting_form_fields;
BEGIN
  -- Verify if the voting form field exists
  IF NOT EXISTS (SELECT 1 FROM voting_form_fields WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting form field found';
  END IF;

  DELETE FROM voting_form_fields
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_form_field;

  RETURN v_voting_form_field;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting form field';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM FIELD BY ID
CREATE OR REPLACE FUNCTION get_voting_form_field_by_id(
  p_id uuid
)
RETURNS SETOF voting_form_fields AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_form_fields
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting form field';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM FIELDS BY VOTING FORM ID
CREATE OR REPLACE FUNCTION get_voting_form_fields_by_voting_form_id(
  p_voting_form_id uuid
)
RETURNS SETOF voting_form_fields AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_form_fields
    WHERE voting_form_id = p_voting_form_id
    ORDER BY order_index;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting form fields';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;