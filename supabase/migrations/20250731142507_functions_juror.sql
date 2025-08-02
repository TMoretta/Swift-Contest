--region GET JOINED CONTESTS AS JUROR
-- Retrieves a list of contests the authenticated user has joined as a juror.
CREATE OR REPLACE FUNCTION juror_get_joined_contests()
RETURNS SETOF jsonb -- Returning a set of JSON objects for consistency.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
BEGIN
  -- It's good practice to verify that the juror's profile exists.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    -- Corrected: Generic error message in English.
    RAISE EXCEPTION 'User profile not found or access denied.';
  END IF;

  -- The query returns the results.
  -- A user can be in multiple juries for the same contest, so we use a subquery
  -- with DISTINCT ON (c.id) to ensure each contest appears only once,
  -- and then we order the final result by creation date.
  RETURN QUERY
  SELECT t.contest_data
  FROM (
    SELECT DISTINCT ON (c.id)
      c.created_at,
      jsonb_build_object(
        -- 1. 'contest_bundle' object.
        'contest_bundle', jsonb_build_object(
          'contest', to_jsonb(c),
          'organizer', to_jsonb(p),
          'place', to_jsonb(pl)
        ),
        -- 2. 'participations' array for the contest.
        'participations', COALESCE(
          (SELECT jsonb_agg(to_jsonb(pa)) FROM public.participations AS pa WHERE pa.contest_id = c.id),
          '[]'::jsonb
        ),
        -- 3. 'jurations' array for the contest.
        'jurations', COALESCE(
          (SELECT jsonb_agg(to_jsonb(ju)) FROM public.jurations AS ju WHERE ju.contest_id = c.id),
          '[]'::jsonb
        )
      ) as contest_data
    FROM
      public.contests AS c
      JOIN public.profiles AS p ON c.organizer_id = p.id
      JOIN public.places AS pl ON c.place_id = pl.id
      -- *** KEY LOGIC ***
      -- JOIN with the jurations table to find contests where the user is a juror.
      JOIN public.jurations user_juration ON c.id = user_juration.contest_id
    WHERE
      -- Filter for the ID of the juror who called the function.
      user_juration.juror_id = auth.uid()
    -- The ORDER BY is crucial for DISTINCT ON.
    ORDER BY c.id, c.created_at DESC
  ) as t
  ORDER BY t.created_at DESC;
END;
$$;
--endregion

--region JUROR JOIN CONTEST
-- Allows an authenticated user to join a jury using an invitation token.
-- If the invitation is valid, it creates a new juration and deletes the invitation.
CREATE OR REPLACE FUNCTION juror_join_contest(p_token uuid)
RETURNS jurations -- Returns the created/existing juration row.
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_invitation record;
  v_juration jurations;
BEGIN
  -- 1. Find the invitation using the provided token.
  SELECT * INTO v_invitation FROM public.juror_invitations WHERE token = p_token;

  -- 2. If the invitation does not exist, raise an exception.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invitation token is invalid or has already been used.';
  END IF;

  -- 3. Check if the user is already a juror in this jury to ensure idempotency.
  SELECT * INTO v_juration FROM public.jurations WHERE jury_id = v_invitation.jury_id AND juror_id = auth.uid();

  IF FOUND THEN
    -- The user is already a juror. The operation is idempotent.
    DELETE FROM public.juror_invitations WHERE id = v_invitation.id;
    RETURN v_juration;
  END IF;

  -- 4. If not already a member, create the new juration row.
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email)
  VALUES (v_invitation.contest_id, v_invitation.jury_id, auth.uid(), v_invitation.email)
  RETURNING * INTO v_juration;

  -- 5. Delete the invitation that was just used.
  DELETE FROM public.juror_invitations WHERE id = v_invitation.id;

  -- 6. Return the new juration.
  RETURN v_juration;
END;
$$;
--endregion

--region JUROR GET VOTING SESSION PROCEDURE BUNDLE
-- Retrieves the data needed for a juror's voting page, tailored to the calling juror.
-- Returns a single JSON object mapping to the Dart class 'JurorVotingSessionProcedureBundle'.
CREATE OR REPLACE FUNCTION juror_get_voting_session_procedure_bundle(p_voting_session_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  v_current_user_id uuid := auth.uid();
  v_current_vs_juror_record public.voting_session_jurors; -- Store the whole record
BEGIN
  -- SECURITY: Find the juror's record for this session to verify access and get their specific IDs.
  -- If no record is found, the user is not a juror for this session, and an exception is raised.
  SELECT *
  INTO v_current_vs_juror_record
  FROM public.voting_session_jurors
  WHERE voting_session_id = p_voting_session_id AND juror_id = v_current_user_id;

  IF v_current_vs_juror_record.id IS NULL THEN
    RAISE EXCEPTION 'Access denied or voting session not found for this juror.';
  END IF;

  -- Build the final JSON object, filtering data based on the juror's specific context.
  SELECT jsonb_build_object(
    -- 1. 'voting_session_bundle' (common for all in the session)
    'voting_session_bundle', (
      SELECT jsonb_build_object(
        'voting_session', to_jsonb(vs),
        'geo_res_place', to_jsonb(pl)
      )
      FROM public.voting_sessions vs
      LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
      WHERE vs.id = p_voting_session_id
    ),

    -- 2. 'voting_session_participants' (common for all in the session)
    'voting_session_participants', (
      SELECT COALESCE(jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index), '[]'::jsonb)
      FROM public.voting_session_participants vsp
      WHERE vsp.voting_session_id = p_voting_session_id
    ),

    -- 3. 'voting_session_jury' (the specific jury the juror belongs to)
    'voting_session_jury', (
      SELECT to_jsonb(vsj)
      FROM public.voting_session_juries vsj
      WHERE vsj.id = v_current_vs_juror_record.voting_session_jury_id
    ),

    -- 4. 'voting_form_bundle' (the form associated with that specific jury)
    'voting_form_bundle', (
      SELECT jsonb_build_object(
        'voting_form', to_jsonb(vf),
        'voting_form_fields', COALESCE((SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index) FROM public.voting_form_fields vff WHERE vff.voting_form_id = vsj.voting_form_id), '[]'::jsonb)
      )
      FROM public.voting_session_juries vsj
      JOIN public.voting_forms vf ON vsj.voting_form_id = vf.id
      WHERE vsj.id = v_current_vs_juror_record.voting_session_jury_id
    ),

    -- 5. 'voting_session_juror' (the specific record for the calling juror)
    'voting_session_juror', to_jsonb(v_current_vs_juror_record),

    -- 6. 'voting_session_participants_exclusions_ids' (only the participant IDs the juror is excluded from)
    'voting_session_participants_exclusions_ids', (
      SELECT COALESCE(jsonb_agg(vse.voting_session_participant_id), '[]'::jsonb)
      FROM public.voting_session_exclusions vse
      WHERE vse.voting_session_juror_id = v_current_vs_juror_record.id
    )
  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion