--region ADMIN GET ALL USERS
CREATE OR REPLACE FUNCTION admin_get_all_users ()
RETURNS SETOF auth.users AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM auth.users;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET ALL PROFILES
CREATE OR REPLACE FUNCTION admin_get_all_profiles ()
RETURNS SETOF profiles AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM profiles;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET USER BY ID
CREATE OR REPLACE FUNCTION admin_get_user_by_id (
  p_user_id uuid
)
RETURNS auth.users AS $$
DECLARE
  v_user auth.users;
BEGIN
  SELECT * INTO v_user
  FROM auth.users
  WHERE id = p_user_id
  LIMIT 1;

  RETURN v_user;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET PROFILE BY ID
CREATE OR REPLACE FUNCTION admin_get_profile_by_user_id (
  p_user_id uuid
)
RETURNS profiles AS $$
DECLARE
  v_profile profiles;
BEGIN
  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id
  LIMIT 1;

  RETURN v_profile;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET CREATED CONTESTS
CREATE OR REPLACE FUNCTION admin_get_user_created_contests(
  p_user_id uuid
)
RETURNS SETOF contests AS $$
DECLARE
  v_profile profiles;
BEGIN

  SELECT * INTO v_profile
  FROM profiles
  WHERE user_id = p_user_id
  LIMIT 1;

  RETURN QUERY
    SELECT *
    FROM contests
    WHERE organizer_id = v_profile.id;

END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET PLACE BY ID
CREATE OR REPLACE FUNCTION admin_get_place_by_id (
  p_place_id uuid
)
RETURNS places AS $$
DECLARE
  v_place places;
BEGIN
  SELECT * INTO v_place
  FROM places
  WHERE id = p_place_id
  LIMIT 1;

  RETURN v_place;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET VOTING FORM BY ID
CREATE OR REPLACE FUNCTION admin_get_voting_form_by_id (
  p_voting_form_id uuid
)
RETURNS voting_forms AS $$
DECLARE
  v_voting_form voting_forms;
BEGIN
  SELECT * INTO v_voting_form
  FROM voting_forms
  WHERE id = p_voting_form_id
  LIMIT 1;

  RETURN v_voting_form;
END;
$$ LANGUAGE plpgsql SECURITY definer;

--region ADMIN GET VOTING FORM FIELDS BY VOTING FORM ID
CREATE OR REPLACE FUNCTION admin_get_voting_form_fields_by_voting_form_id (
  p_voting_form_id uuid
)
RETURNS SETOF voting_form_fields AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM voting_form_fields
    WHERE voting_form_id = p_voting_form_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;



--region ADMIN GET JOINED CONTESTS
--CREATE OR REPLACE FUNCTION admin_get_joined_contests(
--  p_user_id uuid
--)
--RETURNS SETOF contests AS $$
--DECLARE
--  v_profile profiles;
--BEGIN
--
--  SELECT * INTO v_profile
--  FROM profiles
--  WHERE user_id = p_user_id
--  LIMIT 1;
--
--  RETURN QUERY
--    SELECT *
--    FROM contests
--    WHERE organizer_id = v_profile.id;
--
--END;
--$$ LANGUAGE plpgsql SECURITY definer;






























