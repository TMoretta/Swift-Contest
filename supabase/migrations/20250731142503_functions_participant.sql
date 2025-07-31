--region GET JOINED CONTESTS AS PARTICIPANT
-- Retrieves a list of contests the authenticated user has joined.
CREATE OR REPLACE FUNCTION participant_get_joined_contests()
RETURNS SETOF jsonb -- Returning a set of JSON objects for consistency.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
BEGIN
  -- It's good practice to verify that the participant's profile exists.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    -- Corrected: Generic error message in English.
    RAISE EXCEPTION 'User profile not found or access denied.';
  END IF;

  -- The query returns the results, building a single JSON object per row.
  -- The key difference from organizer_get_created_contests is the additional JOIN
  -- on the 'participations' table to filter contests based on the current user.
  RETURN QUERY
  SELECT
    -- Build a single JSON object for each row.
    jsonb_build_object(
      -- 1. 'contest_bundle' object.
      'contest_bundle', jsonb_build_object(
        'contest', to_jsonb(c),
        'organizer', to_jsonb(p),
        'place', to_jsonb(pl)
      ),

      -- 2. 'participations' array for the contest.
      'participations', COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(pa))
          FROM public.participations AS pa
          WHERE pa.contest_id = c.id
        ),
        '[]'::jsonb
      ),

      -- 3. 'jurations' array for the contest.
      'jurations', COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(ju))
          FROM public.jurations AS ju
          WHERE ju.contest_id = c.id
        ),
        '[]'::jsonb
      )
    )
  FROM
    public.contests AS c
    -- JOIN to get the organizer's profile details.
    JOIN public.profiles AS p ON c.organizer_id = p.id
    -- JOIN to get the contest's place details.
    JOIN public.places AS pl ON c.place_id = pl.id
    -- *** KEY LOGIC ***
    -- JOIN with the participations table to find contests the user is part of.
    JOIN public.participations user_participation ON c.id = user_participation.contest_id
  WHERE
    -- Filter for the ID of the participant who called the function.
    user_participation.participant_id = auth.uid()
  ORDER BY
      c.created_at DESC;
END;
$$;
--endregion

--region PARTICIPANT JOIN CONTEST
-- Allows an authenticated user to join a contest using an invitation token.
-- If the invitation is valid, it creates a new participation and deletes the invitation.
CREATE OR REPLACE FUNCTION participant_join_contest(p_token uuid)
RETURNS participations -- MODIFICATION: Returns the created/existing participation row.
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_invitation record;
  v_participation participations;
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
    RETURN v_participation; -- MODIFICATION: Return successfully instead of raising an error.
  END IF;

  -- 4. If not already a member, create the new participation row.
  INSERT INTO public.participations (contest_id, participant_id, invitation_email)
  VALUES (v_invitation.contest_id, auth.uid(), v_invitation.email)
  RETURNING * INTO v_participation; -- Get the newly created row.

  -- 5. Delete the invitation that was just used.
  DELETE FROM public.participant_invitations WHERE id = v_invitation.id;

  -- 6. Return the new participation.
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
SECURITY INVOKER
AS $$
DECLARE
  v_participation record;
  v_contest record;
  new_work_row works;
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
    participant_full_name,
    name,
    description,
    images_urls
  )
  VALUES (
    v_participation.id,
    p_work->>'participant_full_name',
    p_work->>'name',
    p_work->>'description',
    (SELECT array_agg(value) FROM jsonb_array_elements_text(p_work->'images_urls'))
  )
  RETURNING * INTO new_work_row; -- Capture the newly created work row.

  -- 6. Update the 'participations' table to mark the work as submitted.
  UPDATE public.participations
  SET has_submitted = true
  WHERE id = v_participation.id;

  -- 7. Return the new work object to the client.
  RETURN new_work_row;

END;
$$;
--endregion