-- CREATE INVITATION
CREATE OR REPLACE FUNCTION public.create_invitation (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_token varchar(8),
  p_email varchar,
  p_member_role public.member_role
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.invitations (
      id,
      created_at,
      contest_id,
      token,
      email,
      member_role
    )
    VALUES (
      p_id,
      p_created_at,
      p_contest_id,
      p_token,
      p_email,
      p_member_role
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE INVITATION BY ID
CREATE OR REPLACE FUNCTION public.update_invitation (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_token varchar(8),
  p_email varchar,
  p_member_role public.member_role
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    UPDATE public.invitations
    SET
      created_at = p_created_at,
      contest_id = p_contest_id,
      token = p_token,
      email = p_email,
      member_role = p_member_role
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE INVITATION BY ID
CREATE OR REPLACE FUNCTION public.delete_invitation_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.invitations
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATION BY ID
CREATE OR REPLACE FUNCTION public.get_invitation_by_id(
  p_id uuid
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    INTO v_invitation
    FROM public.invitations
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATION BY CONTEST ID AND TOKEN
CREATE OR REPLACE FUNCTION public.get_invitation_by_contest_id_and_token(
  p_contest_id uuid,
  p_token varchar(8)
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    INTO v_invitation
    FROM public.invitations
    WHERE contest_id = p_contest_id AND token = p_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION public.get_invitations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.invitations
    WHERE contest_id = p_contest_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET INVITATIONS BY CONTEST ID AND MEMBER ROLE
CREATE OR REPLACE FUNCTION public.get_invitations_by_contest_id_and_member_role(
  p_contest_id uuid,
  p_member_role public.member_role
)
RETURNS SETOF public.invitations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.invitations
    WHERE contest_id = p_contest_id AND member_role = p_member_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;