--region AUTH GET ACCOUNT BUNDLE
-- Retrieves a complete bundle of user data (account, profile, messages) in a single, efficient call.
-- Returns NULL if the user does not have an associated profile.
CREATE OR REPLACE FUNCTION auth_get_account_bundle()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER SET search_path = public, auth
AS $$
DECLARE
  result_bundle jsonb;
  current_user_id uuid := auth.uid();
BEGIN
  -- This function uses a single query with a LEFT JOIN to be more efficient.
  -- It fetches the user from auth.users and joins their profile if it exists.
  SELECT
    jsonb_build_object(
      -- 1. 'account' object, reshaped to match the client's Account.fromJson factory.
      'account', jsonb_build_object(
        'id', u.id,
        'email', u.email,
        'is_anonymous', u.is_anonymous
      ),

      -- 2. 'profile' object from public.profiles
      -- If the LEFT JOIN finds no profile, to_jsonb(p) will correctly be NULL.
      'profile', to_jsonb(p)

--      -- 3. 'messages' array from public.messages
--      'messages', (
--        SELECT COALESCE(jsonb_agg(to_jsonb(m) ORDER BY m.created_at DESC), '[]'::jsonb)
--        FROM public.messages m
--        WHERE m.account_id = current_user_id
--      )
    ) INTO result_bundle
  FROM auth.users u
  LEFT JOIN public.profiles p ON u.id = p.id
  WHERE u.id = current_user_id;

  -- If the profile was not found, the 'profile' field in the JSON will be null.
  -- In this case, we return NULL for the entire bundle as the user is not fully set up.
  IF result_bundle->'profile' = 'null'::jsonb THEN
      RAISE EXCEPTION 'Profile not found';
  END IF;

  RETURN result_bundle;
END;
$$;
--endregion

 --region AUTH GET MESSAGES
 -- Retrieves all messages for the currently authenticated user.
 CREATE OR REPLACE FUNCTION auth_get_messages()
 RETURNS SETOF messages
 LANGUAGE plpgsql
 STABLE
 SECURITY DEFINER SET search_path = public
 AS $$
 BEGIN
   RETURN QUERY
   SELECT *
   FROM public.messages
   WHERE account_id = auth.uid()
   ORDER BY created_at DESC;
 END;
 $$;
 --endregion

--region AUTH CHECK ACCOUNT EXISTS
-- Checks if a user exists in auth.users for a given email.
-- This is a public-facing function that can be called without authentication.
CREATE OR REPLACE FUNCTION public.auth_check_account_exists(p_email text)
RETURNS boolean
LANGUAGE plpgsql
STABLE
-- SECURITY DEFINER is used to query the auth.users table, which is normally restricted.
SECURITY DEFINER SET search_path = auth
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM auth.users
    WHERE lower(email) = lower(p_email) -- Case-insensitive check
  );
END;
$$;

--region MARK MESSAGE AS READ
-- Marks a specific message as read for the authenticated user.
CREATE OR REPLACE FUNCTION auth_mark_message_as_read(p_message_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, extensions -- The function runs with the permissions of the user calling it.
AS $$
BEGIN
  -- Update the 'is_read' status of a specific message.
  -- The WHERE clause ensures that users can only update their own messages.
  UPDATE public.messages
  SET is_read = true
  WHERE id = p_message_id AND account_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Message not found or access denied.';
  END IF;
END;
$$;
--endregion

--region DELETE MESSAGE
-- Deletes a specific message owned by the authenticated user.
CREATE OR REPLACE FUNCTION auth_delete_message(p_message_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public -- The function runs with the permissions of the user calling it.
AS $$
BEGIN
  -- Delete the message from the public.messages table.
  -- The WHERE clause is a security measure, ensuring that a user can only delete their own messages.
  DELETE FROM public.messages
  WHERE id = p_message_id AND account_id = auth.uid();

  -- If no row was deleted (either because the message ID didn't exist or
  -- it didn't belong to the user), the 'FOUND' variable will be false.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Message not found or access denied.';
  END IF;
END;
$$;
--endregion

--region DELETE ALL ACCOUNT MESSAGES
-- Deletes all messages for the currently authenticated user.
CREATE OR REPLACE FUNCTION auth_delete_all_account_messages()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM messages
    WHERE account_id = auth.uid()
  ) THEN
    RETURN; -- No messages to delete
  END IF;

  -- Delete all messages where the account_id matches the caller's user ID.
  DELETE FROM public.messages
  WHERE account_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'An error occurred while deleting all messages.';
  END IF;
END;
$$;
--endregion

--region UPDATE PROFILE FULL NAME
-- Updates the full_name for the currently authenticated user's profile.
CREATE OR REPLACE FUNCTION auth_update_profile_full_name(p_full_name text)
RETURNS void -- Returns the single updated profile row
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  UPDATE public.profiles
  SET full_name = p_full_name
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found or access denied.';
  END IF;
END;
$$;
--endregion

--region UPDATE PROFILE PREFERRED ROLE
-- Updates the pref_role for the currently authenticated user's profile.
CREATE OR REPLACE FUNCTION auth_update_profile_pref_role(p_pref_role text)
RETURNS void -- Returns the single updated profile row
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  UPDATE public.profiles
  SET pref_role = p_pref_role::contest_role -- Cast the text input to the enum type
  WHERE id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found or access denied.';
  END IF;
END;
$$;
--endregion