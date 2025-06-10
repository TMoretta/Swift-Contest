-- CREATE VOTING FORM
CREATE OR REPLACE FUNCTION create_voting_form (
  p_voting_form voting_forms
)
RETURNS voting_forms AS $$
DECLARE
  v_voting_form voting_forms;
BEGIN
  INSERT INTO voting_forms (
    id,
    created_at
  )
  VALUES (
    p_voting_form.id,
    p_voting_form.created_at
  )
  RETURNING * INTO STRICT v_voting_form;

  RETURN v_voting_form;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the voting form';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING FORM BY ID
--CREATE OR REPLACE FUNCTION update_voting_form (
--  p_id uuid,
--  p_created_at timestamptz
--)
--RETURNS voting_forms AS $$
--BEGIN
--    UPDATE voting_forms
--    SET
--    WHERE id = p_id
--    RETURNING *;
--END;
--$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING FORM BY ID
CREATE OR REPLACE FUNCTION delete_voting_form_by_id(
  p_id uuid
)
RETURNS voting_forms AS $$
DECLARE
  v_voting_form voting_forms;
BEGIN
  -- Verify if the voting form exists
  IF NOT EXISTS (SELECT 1 FROM voting_forms WHERE id = p_id) THEN
    RAISE EXCEPTION 'No voting form found';
  END IF;

  DELETE FROM voting_forms
  WHERE id = p_id
  RETURNING * INTO STRICT v_voting_form;

  RETURN v_voting_form;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the voting form';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM BY ID
CREATE OR REPLACE FUNCTION get_voting_form_by_id(
  p_id uuid
)
RETURNS SETOF voting_forms AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_forms
    WHERE id = p_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the voting form';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;