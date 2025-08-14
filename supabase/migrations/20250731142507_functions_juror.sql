--region GET JOINED CONTESTS AS JUROR
-- Retrieves a list of contests the authenticated user has joined as a juror.
CREATE OR REPLACE FUNCTION juror_get_joined_contests()
RETURNS SETOF jsonb -- Returning a set of JSON objects for consistency.
LANGUAGE plpgsql
STABLE
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Security check: Ensure the user has a profile before proceeding.
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'User profile not found.';
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
        -- 2. 'participants_number'
         'participants_number', (
           SELECT COUNT(*)::int
           FROM public.participations pa
           WHERE pa.contest_id = c.id
         ),
         -- 3. 'jurors_number'
         'jurors_number', (
           SELECT COUNT(*)::int
           FROM public.jurations ju
           WHERE ju.contest_id = c.id
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

 --region JUROR GET CONTEST DETAILS BUNDLE
 -- Retrieves a tailored bundle of contest details for a specific juror.
 CREATE OR REPLACE FUNCTION juror_get_contest_details(p_contest_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 -- Runs with the permissions of the calling user.
 -- Added search_path for security and consistency.
 SECURITY DEFINER SET search_path = public
 AS $$
 DECLARE
   result_bundle jsonb;
   current_user_id uuid := auth.uid();
 BEGIN
   -- Step 1: Security Check - Ensure the caller is a juror in this contest.
   IF NOT EXISTS (
     SELECT 1
     FROM public.jurations
     WHERE contest_id = p_contest_id AND juror_id = current_user_id
   ) THEN
     RAISE EXCEPTION 'Access denied or contest not found.';
   END IF;

   -- Step 2: Build the JSON response tailored for the juror view.
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
     'participants_number', (SELECT COUNT(*)::int FROM public.participations WHERE contest_id = p_contest_id),
     'jurors_number', (SELECT COUNT(*)::int FROM public.jurations WHERE contest_id = p_contest_id),
     'contest_rankings', (SELECT COALESCE(jsonb_agg(to_jsonb(cr)), '[]'::jsonb) FROM public.contest_rankings cr WHERE cr.contest_id = p_contest_id),
      'live_voting_session_bundle', (
        SELECT jsonb_build_object(
          'voting_session', to_jsonb(vs),
          'place', to_jsonb(pl)
        )
        FROM public.voting_sessions vs
        LEFT JOIN public.places pl ON vs.geo_res_place_id = pl.id
        WHERE vs.contest_id = p_contest_id AND vs.session_status = 'live'
        LIMIT 1 -- Ensures only one (or null) is returned
      )
   )
   INTO result_bundle;

   RETURN result_bundle;
 END;
 $$;
 --endregion

--region JUROR JOIN CONTEST
-- Allows an authenticated user to join a jury using an invitation token.
-- If the invitation is valid, it creates a new juration and deletes the invitation.
CREATE OR REPLACE FUNCTION juror_join_contest(p_token uuid)
RETURNS jurations -- Returns the created/existing juration row.
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public
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

--region JUROR LEAVE CONTEST
 -- Allows a juror to leave a contest, deleting their juration(s) for that contest.
 CREATE OR REPLACE FUNCTION juror_leave_contest(p_contest_id uuid)
  RETURNS void
  LANGUAGE plpgsql
  -- Runs with creator's privileges to insert a message for the organizer.
  -- Security is enforced by checking that the user is the juror.
  SECURITY DEFINER SET search_path = public
  AS $$
  DECLARE
    v_contest record;
    v_juror_name text;
    v_jurations_found boolean;
  BEGIN
    -- SECURITY CHECK: Verify that the user is actually a juror in this contest.
    SELECT EXISTS(
      SELECT 1 FROM public.jurations
      WHERE contest_id = p_contest_id AND juror_id = auth.uid()
    ) INTO v_jurations_found;

    IF NOT v_jurations_found THEN
      RAISE EXCEPTION 'Juration not found for this user in the specified contest.';
    END IF;

    -- Get contest and juror details for the notification message.
    SELECT name, organizer_id INTO v_contest FROM public.contests WHERE id = p_contest_id;
    SELECT full_name INTO v_juror_name FROM public.profiles WHERE id = auth.uid();

    -- Delete all juration records for the user in this contest.
    DELETE FROM public.jurations WHERE contest_id = p_contest_id AND juror_id = auth.uid();

    -- Create a notification message for the organizer.
    INSERT INTO public.messages (account_id, title, body)
    VALUES (
      v_contest.organizer_id,
      'Juror Left Contest',
      'The juror "' || v_juror_name || '" has left your contest "' || v_contest.name || '".'
    );
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
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public
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

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Access denied or juror not found in this voting session.';
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

--region JUROR SUBMIT VOTES
-- Allows a juror to submit their votes for a session.
-- The operation is transactional and uses the new flexible schema.
CREATE OR REPLACE FUNCTION juror_submit_votes(
  p_voting_session_id uuid,
  -- The payload is a flat list of all values.
  -- Example: '[{"voting_form_field_id": "...", "value": "...", "voting_session_participant_id": "..."}, ...]'
  -- 'voting_session_participant_id' is NULL for 'header' or 'footer' scope fields.
  p_votes_payload jsonb,
  p_juror_lat float DEFAULT NULL,
  p_juror_lon float DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
-- Runs with the permissions of the calling user.
-- Added search_path for security and consistency.
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_session record;
  v_juror_record public.voting_session_jurors;
  v_geo_res_place record;
  v_submission_id uuid; -- ID of the new row in form_submissions
BEGIN
  -- STEP 1: SECURITY AND PRE-CHECKS
  -- Retrieve the juror's record for this session using the caller's ID.
  SELECT * INTO v_juror_record
  FROM public.voting_session_jurors
  WHERE voting_session_id = p_voting_session_id AND juror_id = auth.uid();

  -- If no record is found, the user is not a juror for this session.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Access denied or not a juror in this voting session.';
  END IF;

  -- Check if votes have already been submitted.
  IF v_juror_record.has_submitted THEN
    RAISE EXCEPTION 'Votes for this session have already been submitted.';
  END IF;

  -- Check the session status.
  SELECT * INTO v_session FROM public.voting_sessions WHERE id = p_voting_session_id;
  IF v_session.session_status <> 'live' THEN
    RAISE EXCEPTION 'The voting session is not currently live.';
  END IF;

  -- STEP 2: GEO-RESTRICTION CHECK
  IF v_session.is_geo_restricted THEN
    IF p_juror_lat IS NULL OR p_juror_lon IS NULL THEN
      RAISE EXCEPTION 'Location data is required for this voting session.';
    END IF;
    -- NOTE: This check requires the 'postgis' extension to be enabled.
    SELECT * INTO v_geo_res_place FROM public.places WHERE id = v_session.geo_res_place_id;
    -- Use PostGIS to verify the distance.
    IF NOT ST_DWithin(
      ST_MakePoint(v_geo_res_place.lon, v_geo_res_place.lat)::geography,
      ST_MakePoint(p_juror_lon, p_juror_lat)::geography,
      v_session.geo_res_radius
    ) THEN
      RAISE EXCEPTION 'You are not within the allowed geographical area for voting.';
    END IF;
  END IF;

  -- STEP 3: SAVE VOTES
  -- 3a. Create a single submission record.
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id)
  VALUES (p_voting_session_id, v_juror_record.id)
  RETURNING id INTO v_submission_id;

  -- 3b. Insert all vote values from the payload in a single, efficient operation.
  INSERT INTO public.voting_form_submission_values (
    voting_form_submission_id,
    voting_form_field_id,
    value,
    voting_session_participant_id
  )
  SELECT
    v_submission_id,
    (value->>'voting_form_field_id')::uuid,
    (value->>'value')::text,
    (value->>'voting_session_participant_id')::uuid -- Will be NULL if the key is not in the JSON object.
  FROM jsonb_array_elements(p_votes_payload) AS value;

  -- STEP 4: UPDATE JUROR STATUS
  UPDATE public.voting_session_jurors
  SET has_submitted = true
  WHERE id = v_juror_record.id;

END;
$$;
--endregion

--region JUROR ACCESS VOTING AS SIMPLE JUROR
CREATE OR REPLACE FUNCTION juror_access_voting_as_simple_juror(p_token uuid)
RETURNS voting_sessions -- Returns the voting session the simple juror has accessed.
LANGUAGE plpgsql
-- Runs with creator's privileges to check for appointed status and insert the simple juror.
-- SECURITY DEFINER is safe here due to rigorous checks. search_path is critical.
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_voting_session voting_sessions;
  v_session_jury RECORD;
  v_is_appointed_juror BOOLEAN;
  v_user_full_name TEXT;
BEGIN
  -- 1. Find a 'simple' jury in a 'live' session with the provided token.
  SELECT vsj.*
  INTO v_session_jury
  FROM public.voting_session_juries vsj
  JOIN public.voting_sessions vs ON vsj.voting_session_id = vs.id
  WHERE vsj.jury_token = p_token
    AND vsj.jury_type = 'simple'
    AND vs.session_status = 'live';

  -- 2. If no match is found, raise an exception.
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid invitation token or voting session is not active.';
  END IF;

  -- 3. Check if the current user is already an 'appointed' juror in any jury.
  SELECT EXISTS (
    SELECT 1
    FROM public.jurations j
    JOIN public.juries ON j.jury_id = juries.id
    WHERE j.juror_id = auth.uid()
      AND juries.type = 'appointed'
  )
  INTO v_is_appointed_juror;

  -- 4. If the user is an 'appointed' juror, they cannot use a simple juror token.
  IF v_is_appointed_juror THEN
    RAISE EXCEPTION 'You are an appointed juror and must vote in the dedicated section within the contest.';
  END IF;

  -- 5. If checks pass, proceed with inserting the 'simple' juror.
  --    First, retrieve the user's full name from their profile.
  SELECT full_name
  INTO v_user_full_name
  FROM public.profiles
  WHERE id = auth.uid();

  -- If the profile doesn't exist, we can't proceed.
  IF NOT FOUND THEN
      RAISE EXCEPTION 'User profile not found.';
  END IF;

  -- Insert the new record into voting_session_jurors.
  -- ON CONFLICT DO NOTHING handles the case where the user clicks the link multiple times,
  -- preventing duplicate errors.
  INSERT INTO public.voting_session_jurors (
    voting_session_id,
    voting_session_jury_id,
    juration_id,
    juror_id,
    juror_full_name
  )
  VALUES (
    v_session_jury.voting_session_id,
    v_session_jury.id,
    NULL, -- juration_id is null for 'simple' jurors
    auth.uid(),
    v_user_full_name
  )
  ON CONFLICT (voting_session_jury_id, juror_id) DO NOTHING;

  -- 6. Finally, return the full row of the voting session the user has accessed.
  SELECT * INTO v_voting_session
  FROM public.voting_sessions
  WHERE id = v_session_jury.voting_session_id;

  IF NOT FOUND THEN
    -- This is an unlikely internal error, but good to have.
    RAISE EXCEPTION 'Voting session could not be retrieved after access was granted.';
  END IF;

  RETURN v_voting_session;

END;
$$;