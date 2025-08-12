--region AUTH GET ACCOUNT BUNDLE
-- Retrieves a complete bundle of user data (account, profile, messages) in a single call.
-- Returns NULL if the user does not have an associated profile.
CREATE OR REPLACE FUNCTION auth_get_account_bundle()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  result_bundle jsonb;
  current_user_id uuid := auth.uid();
BEGIN
  -- First, check if a profile exists for the user.
  -- If not, we consider the user not fully set up and return NULL.
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = current_user_id) THEN
    RETURN NULL;
  END IF;

  -- If the profile exists, proceed to build the complete bundle.
  SELECT
    jsonb_build_object(
      -- 1. 'account' object, reshaped to match the client's Account.fromJson factory.
      'account', (
        SELECT jsonb_build_object(
            'id', u.id,
            'email', u.email,
            'is_admin', COALESCE((u.raw_user_meta_data->>'is_admin')::boolean, false),
            'is_anonymous', u.is_anonymous
        )
        FROM auth.users u
        WHERE u.id = current_user_id
      ),

      -- 2. 'profile' object from public.profiles
      'profile', (
        SELECT to_jsonb(p)
        FROM public.profiles p
        WHERE p.id = current_user_id
      ),

      -- 3. 'messages' array from public.messages
      'messages', (
        SELECT COALESCE(jsonb_agg(to_jsonb(m) ORDER BY m.created_at DESC), '[]'::jsonb)
        FROM public.messages m
        WHERE m.account_id = current_user_id
      )
    )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region MARK MESSAGE AS READ
-- Marks a specific message as read for the authenticated user.
CREATE OR REPLACE FUNCTION auth_mark_message_as_read(p_message_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER -- The function runs with the permissions of the user calling it.
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
SECURITY INVOKER -- The function runs with the permissions of the user calling it.
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
SECURITY INVOKER
AS $$
BEGIN
  -- Delete all messages where the account_id matches the caller's user ID.
  DELETE FROM public.messages
  WHERE account_id = auth.uid();
END;
$$;
--endregion

--region UPDATE PROFILE FULL NAME
-- Updates the full_name for the currently authenticated user's profile.
CREATE OR REPLACE FUNCTION auth_update_profile_full_name(p_full_name text)
RETURNS profiles -- Returns the single updated profile row
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  updated_profile profiles;
BEGIN
  UPDATE public.profiles
  SET full_name = p_full_name
  WHERE id = auth.uid()
  RETURNING * INTO updated_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found or access denied.';
  END IF;

  RETURN updated_profile;
END;
$$;
--endregion

--region UPDATE PROFILE PREFERRED ROLE
-- Updates the pref_role for the currently authenticated user's profile.
CREATE OR REPLACE FUNCTION auth_update_profile_pref_role(p_pref_role text)
RETURNS profiles -- Returns the single updated profile row
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  updated_profile profiles;
BEGIN
  UPDATE public.profiles
  SET pref_role = p_pref_role::contest_role -- Cast the text input to the enum type
  WHERE id = auth.uid()
  RETURNING * INTO updated_profile;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profile not found or access denied.';
  END IF;

  RETURN updated_profile;
END;
$$;
--endregion