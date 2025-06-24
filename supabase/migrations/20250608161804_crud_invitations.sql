-- CREATE INVITATION
CREATE OR REPLACE FUNCTION create_invitation (
  p_invitation invitations
)
RETURNS invitations AS $$
DECLARE
  v_invitation invitations;
BEGIN
  INSERT INTO invitations (
    id,
    created_at,
    contest_id,
    token,
    email,
    member_role
  )
  VALUES (
    p_invitation.id,
    p_invitation.created_at,
    p_invitation.contest_id,
    p_invitation.token,
    p_invitation.email,
    p_invitation.member_role
  )
  RETURNING * INTO STRICT v_invitation;

  RETURN v_invitation;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating the invitation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE INVITATION BY ID
CREATE OR REPLACE FUNCTION update_invitation (
  p_invitation invitations
)
RETURNS invitations AS $$
DECLARE
  v_invitation invitations;
BEGIN
  -- Verify if the invitation exists
  IF NOT EXISTS (SELECT 1 FROM invitations WHERE id = p_invitation.id) THEN
    RAISE EXCEPTION 'No invitation found';
  END IF;

  UPDATE invitations
  SET
    contest_id = p_invitation.contest_id,
    token = p_invitation.token,
    email = p_invitation.email,
    member_role = p_invitation.member_role
  WHERE id = p_invitation.id
  RETURNING * INTO STRICT v_invitation;

  RETURN v_invitation;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while updating the invitation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE INVITATION BY ID
CREATE OR REPLACE FUNCTION delete_invitation_by_id(
  p_id uuid
)
RETURNS invitations AS $$
DECLARE
  v_invitation invitations;
BEGIN
  -- Verify if the invitation exists
  IF NOT EXISTS (SELECT 1 FROM invitations WHERE id = p_id) THEN
    RAISE EXCEPTION 'No invitation found';
  END IF;

  DELETE FROM invitations
  WHERE id = p_id
  RETURNING * INTO STRICT v_invitation;
  
  RETURN v_invitation;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while deleting the invitation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATION BY ID
CREATE OR REPLACE FUNCTION get_invitation_by_id(
  p_id uuid
)
RETURNS SETOF invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM invitations
    WHERE id = p_id;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the invitation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATION BY CONTEST ID AND TOKEN
CREATE OR REPLACE FUNCTION get_invitation_by_contest_id_and_token(
  p_contest_id uuid,
  p_token varchar
)
RETURNS SETOF invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM invitations
    WHERE contest_id = p_contest_id AND token = p_token;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the invitation';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION get_invitations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM invitations
    WHERE contest_id = p_contest_id;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the invitations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATIONS BY CONTEST ID AND MEMBER ROLE
CREATE OR REPLACE FUNCTION get_invitations_by_contest_id_and_member_role(
  p_contest_id uuid,
  p_member_role member_role
)
RETURNS SETOF invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM invitations
    WHERE contest_id = p_contest_id AND member_role = p_member_role;
    
EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting the invitations';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;