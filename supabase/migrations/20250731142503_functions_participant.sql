--region GET JOINED CONTESTS AS PARTICIPANT
-- Retrieves a list of contests the authenticated user has joined.
CREATE OR REPLACE FUNCTION participant_get_joined_contests()
RETURNS SETOF jsonb -- Returning a set of JSON objects for consistency.
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
BEGIN
  -- Security check: Ensure the user has a profile before proceeding.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'User profile not found.';
  END IF;

  RETURN QUERY
  SELECT
    jsonb_build_object(
      'contest_bundle', jsonb_build_object(
        'contest', to_jsonb(c),
        'organizer', to_jsonb(p),
        'place', to_jsonb(pl)
      ),
      'participants_number', (
        SELECT COUNT(*)::int
        FROM public.participations pa
        WHERE pa.contest_id = c.id
      ),
      'jurors_number', (
        SELECT COUNT(*)::int
        FROM public.jurations ju
        WHERE ju.contest_id = c.id
      )
    )
  FROM
    public.contests AS c
    JOIN public.profiles AS p ON c.organizer_id = p.id
    JOIN public.places AS pl ON c.place_id = pl.id
    JOIN public.participations user_participation ON c.id = user_participation.contest_id
  WHERE
    user_participation.participant_id = auth.uid()
  ORDER BY
      c.created_at DESC;
END;
$$;
--endregion

--region PARTICIPANT GET CONTEST DETAILS BUNDLE
 -- Retrieves a tailored bundle of contest details for a specific participant.
 CREATE OR REPLACE FUNCTION participant_get_contest_details(p_contest_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- Runs with the permissions of the calling user.
 -- Added search_path for security and consistency.
 SECURITY DEFINER SET search_path = public, extensions
 AS $$
 DECLARE
   result_bundle jsonb;
   current_user_id uuid := auth.uid();
 BEGIN
   -- SECURITY CHECK: Ensure the caller is a participant in this contest.
   IF NOT EXISTS (
     SELECT 1
     FROM public.participations
     WHERE contest_id = p_contest_id AND participant_id = current_user_id
   ) THEN
     RAISE EXCEPTION 'Access denied or contest not found.';
   END IF;

   -- If the check passes, build the JSON response tailored for the participant view.
   SELECT jsonb_build_object(
     'contest_bundle', (
       SELECT jsonb_build_object(
         'contest', to_jsonb(c),
         'organizer', to_jsonb(p),
         'place', to_jsonb(pl)
       )
       FROM public.contests c
       JOIN public.profiles p ON c.organizer_id = p.id
       JOIN public.places pl ON c.place_id = pl.id
       WHERE c.id = p_contest_id
     ),
     'participants_number', (
       SELECT COUNT(*)::int FROM public.participations WHERE contest_id = p_contest_id
     ),
     'jurors_number', (
       SELECT COUNT(*)::int FROM public.jurations WHERE contest_id = p_contest_id
     ),
     'contest_rankings', (
       SELECT COALESCE(jsonb_agg(to_jsonb(cr)), '[]'::jsonb)
       FROM public.contest_rankings cr
       WHERE cr.contest_id = p_contest_id
     ),
     'own_work', (
       SELECT to_jsonb(w)
       FROM public.works w
       JOIN public.participations pa ON w.participation_id = pa.id
       WHERE pa.contest_id = p_contest_id AND pa.participant_id = current_user_id
     )
   )
   INTO result_bundle;

   RETURN result_bundle;
 END;
 $$;
 --endregion

--region PARTICIPANT JOIN CONTEST
-- Allows an authenticated user to join a contest using an invitation token.
-- If the invitation is valid, it creates a new participation and deletes the invitation.
CREATE OR REPLACE FUNCTION participant_join_contest(p_token varchar)
RETURNS participations -- MODIFICATION: Returns the created/existing participation row.
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_invitation record;
  v_participation participations;
  v_contest record;
  v_participant_name text;
BEGIN
  -- 1. Find the invitation using the provided token.
  SELECT *
  INTO v_invitation
  FROM public.participant_invitations
  WHERE token = p_token;

  -- 2. If the invitation does not exist, raise an exception.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invitation token is invalid or has already been used.';
  END IF;

  -- 3. Check if the user is already a participant in this contest to ensure idempotency.
  SELECT *
  INTO v_participation
  FROM public.participations
  WHERE contest_id = v_invitation.contest_id AND participant_id = auth.uid();

  IF FOUND THEN
    -- The user is already a participant. The operation is idempotent.
    -- Clean up the used invitation token and return the existing participation.
    DELETE FROM public.participant_invitations WHERE id = v_invitation.id;
    RETURN v_participation;
  END IF;

  -- 4. If not already a member, create the new participation row.
  INSERT INTO public.participations (contest_id, participant_id, invitation_email)
  VALUES (v_invitation.contest_id, auth.uid(), v_invitation.email)
  RETURNING * INTO v_participation; -- Get the newly created row.
  
  -- 5. Get contest and participant details for the notification message.
  SELECT name, organizer_id INTO v_contest FROM public.contests WHERE id = v_invitation.contest_id;
  SELECT full_name INTO v_participant_name FROM public.profiles WHERE id = auth.uid();

  -- 6. Create a notification message for the organizer.
  INSERT INTO public.messages (account_id, title, body)
  VALUES (
    v_contest.organizer_id,
    'New Participant Joined',
    'The participant "' || v_participant_name || '" has joined your contest "' || v_contest.name || '".'
  );

  -- 7. Delete the invitation that was just used.
  DELETE FROM public.participant_invitations WHERE id = v_invitation.id;

  -- 8. Return the new participation.
  RETURN v_participation;
END;
$$;
--endregion

--region SUBMIT WORK
-- Allows a participant to submit their work for a contest.
-- It performs validity checks (submission period, existing participation)
-- and updates the state transactionally.
CREATE OR REPLACE FUNCTION participant_submit_work(p_contest_id uuid, p_work jsonb)
RETURNS works -- MODIFICATION: Returns the newly created work row.
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public, extensions
AS $$
DECLARE
  v_participation record;
  v_contest record;
  new_work_row works;
  v_participant_name text;
BEGIN
  -- 1. Retrieve contest details to check submission dates.
  SELECT *
  INTO v_contest
  FROM public.contests
  WHERE id = p_contest_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Contest not found.';
  END IF;

  -- 2. KEY CHECK: Verify that the current date is within the submission period.
  IF now() NOT BETWEEN v_contest.works_submission_start AND v_contest.works_submission_end THEN
    RAISE EXCEPTION 'The submission period for works is not active.';
  END IF;

  -- 3. Find the current user's participation for this contest.
  SELECT *
  INTO v_participation
  FROM public.participations
  WHERE contest_id = p_contest_id AND participant_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'You are not a participant in this contest.';
  END IF;

  -- 4. Check if the user has already submitted a work.
  IF v_participation.has_submitted THEN
    RAISE EXCEPTION 'You have already submitted a work for this contest.';
  END IF;

  -- 5. Create the new record in the 'works' table.
  INSERT INTO public.works (
    participation_id,
    name,
    description,
    images_paths
  )
  VALUES (
    v_participation.id,
    p_work->>'name',
    p_work->>'description',
    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_work->'images_paths'))
  )
  RETURNING * INTO new_work_row; -- Capture the newly created work row.

  -- 6. Update the 'participations' table to mark the work as submitted.
  UPDATE public.participations
  SET has_submitted = true
  WHERE id = v_participation.id;

  -- 7. Get participant name for the notification.
  SELECT full_name INTO v_participant_name FROM public.profiles WHERE id = auth.uid();

  -- 8. Create a notification message for the organizer.
  INSERT INTO public.messages (account_id, title, body)
  VALUES (
    v_contest.organizer_id,
    'Work Submitted',
    'The participant "' || v_participant_name || '" has submitted their work for your contest "' || v_contest.name || '".'
  );

  -- 9. Return the new work object to the client.
  RETURN new_work_row;

END;
$$;
--endregion
