--region USER GET CONTEST DETAILS BUNDLE
-- Retrieves all nested data for a contest's detail page.
-- The data returned is tailored to the role of the calling user (organizer, participant, or juror).
CREATE OR REPLACE FUNCTION user_get_contest_details(p_contest_id uuid)
RETURNS jsonb -- Returns a single, complex JSONB object.
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  is_organizer boolean;
  is_participant boolean;
  is_juror boolean;
  current_user_id uuid := auth.uid();
BEGIN
  -- Step 1: Determine the user's role for THIS specific contest.
  SELECT EXISTS (SELECT 1 FROM public.contests WHERE id = p_contest_id AND organizer_id = current_user_id) INTO is_organizer;
  SELECT EXISTS (SELECT 1 FROM public.participations WHERE contest_id = p_contest_id AND participant_id = current_user_id) INTO is_participant;
  SELECT EXISTS (SELECT 1 FROM public.jurations WHERE contest_id = p_contest_id AND juror_id = current_user_id) INTO is_juror;

  -- Step 2: Security Check. If the user has no role, deny access.
  IF NOT (is_organizer OR is_participant OR is_juror) THEN
    RAISE EXCEPTION 'Access denied or contest not found.';
  END IF;

  -- Step 3: Build the JSON response, conditionally including data based on the user's role.
  SELECT jsonb_build_object(
    -- 'contest_bundle' is visible to everyone with access.
    'contest_bundle', (
      SELECT row_to_json(cb)
      FROM public.contest_bundles cb
      WHERE (cb.contest->>'id')::uuid = p_contest_id
    ),

    -- 'participations_bundles' are visible to everyone with access.
    'participations_bundles', (
      SELECT COALESCE(jsonb_agg(row_to_json(pb)), '[]'::jsonb)
      FROM public.participation_bundles pb
      WHERE (pb.participation->>'contest_id')::uuid = p_contest_id
    ),

    -- 'participants_invitations' are visible ONLY to the organizer.
    'participants_invitations', CASE
      WHEN is_organizer THEN (
        SELECT COALESCE(jsonb_agg(to_jsonb(pi)), '[]'::jsonb)
        FROM public.participant_invitations pi
        WHERE pi.contest_id = p_contest_id
      )
      ELSE '[]'::jsonb
    END,

    -- 'juries_bundles' are visible ONLY to the organizer.
    'juries_bundles', CASE
      WHEN is_organizer THEN (
        SELECT COALESCE(jsonb_agg(row_to_json(jb)), '[]'::jsonb)
        FROM public.jury_bundles jb
        WHERE (jb.jury->>'contest_id')::uuid = p_contest_id
      )
      ELSE '[]'::jsonb
    END,

    -- 'voting_sessions_bundles' are visible to organizers and jurors.
    'voting_sessions_bundles', CASE
      WHEN is_organizer OR is_juror THEN (
        SELECT COALESCE(jsonb_agg(row_to_json(vsb)), '[]'::jsonb)
        FROM public.voting_session_bundles vsb
        WHERE (vsb.voting_session->>'contest_id')::uuid = p_contest_id
      )
      ELSE '[]'::jsonb
    END
  )
  INTO result_bundle;

  RETURN result_bundle;
END;
$$;
--endregion

--region USER GET PARTICIPATION BUNDLE
-- Retrieves the details of a single participation (participation, participant, and work).
-- Access is granted to the contest organizer or the specific participant.
CREATE OR REPLACE FUNCTION user_get_participation_bundle(p_participation_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
BEGIN
  -- SECURITY CHECK: Verify that the current user is either:
  -- 1. The organizer of the contest this participation belongs to.
  -- 2. The participant of this specific participation.
  IF NOT EXISTS (
    SELECT 1
    FROM public.participations pa
    JOIN public.contests c ON pa.contest_id = c.id
    WHERE
      pa.id = p_participation_id
      AND (c.organizer_id = auth.uid() OR pa.participant_id = auth.uid())
  ) THEN
    RAISE EXCEPTION 'Participation not found or access denied.';
  END IF;

  -- If the security check passes, build the bundle.
  SELECT jsonb_build_object(
           'participation', to_jsonb(pa),
           'participant', to_jsonb(p),
           'work', to_jsonb(w)
         )
  INTO result_bundle
  FROM public.participations pa
  JOIN public.profiles p ON pa.participant_id = p.id
  LEFT JOIN public.works w ON pa.id = w.participation_id
  WHERE pa.id = p_participation_id;

  RETURN result_bundle;
END;
$$;

--region USER GET JURY BUNDLE
-- Retrieves the complete details of a single jury.
-- Access is granted to the contest organizer or any juror who is a member of that jury.
CREATE OR REPLACE FUNCTION user_get_jury_bundle(p_jury_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  is_organizer boolean;
  is_juror boolean;
BEGIN
  -- SECURITY CHECK: Determine if the current user is the organizer or a member of this jury.

  -- 1. Check if the user is the organizer of the contest.
  SELECT EXISTS (
    SELECT 1
    FROM public.juries j
    JOIN public.contests c ON j.contest_id = c.id
    WHERE j.id = p_jury_id AND c.organizer_id = auth.uid()
  ) INTO is_organizer;

  -- 2. Check if the user is a juror in this specific jury.
  SELECT EXISTS (
    SELECT 1
    FROM public.jurations ju
    WHERE ju.jury_id = p_jury_id AND ju.juror_id = auth.uid()
  ) INTO is_juror;

  -- 3. If the user is neither, deny access.
  IF NOT (is_organizer OR is_juror) THEN
    RAISE EXCEPTION 'Jury not found or access denied.';
  END IF;

  -- If the security check passes, build the complete jury bundle.
  SELECT
       jsonb_build_object(
         'jury', to_jsonb(j),

         -- Build the 'jurations_bundles' array
         'jurations_bundles', COALESCE(
           (
             SELECT jsonb_agg(
               jsonb_build_object('juration', to_jsonb(ju), 'juror', to_jsonb(p_juror))
             )
             FROM public.jurations ju
             JOIN public.profiles p_juror ON ju.juror_id = p_juror.id
             WHERE ju.jury_id = j.id
           ),
           '[]'::jsonb
         ),

         -- Build the 'jurors_invitations' array
         'jurors_invitations', COALESCE(
           (
             SELECT jsonb_agg(to_jsonb(ji))
             FROM public.juror_invitations ji
             WHERE ji.jury_id = j.id
           ),
           '[]'::jsonb
         ),

         -- Build the 'voting_form_bundle' object
         'voting_form_bundle', (
           SELECT jsonb_build_object(
             'voting_form', to_jsonb(vf),
             'voting_form_fields', COALESCE(
               (
                 SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
                 FROM public.voting_form_fields vff
                 WHERE vff.voting_form_id = vf.id
               ),
               '[]'::jsonb
             )
           )
           FROM public.voting_forms vf
           WHERE vf.id = j.voting_form_id
         )
       )
     INTO result_bundle
     FROM public.juries j
     WHERE j.id = p_jury_id;

     RETURN result_bundle;
END;
$$;

--region USER GET VOTING FORM BUNDLE
-- Retrieves a voting form and all its associated fields.
-- Access is granted to the contest organizer or any juror whose jury uses this form.
CREATE OR REPLACE FUNCTION user_get_voting_form_bundle(p_voting_form_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result_bundle jsonb;
  is_organizer boolean;
  is_juror boolean;
BEGIN
  -- SECURITY CHECK: Determine if the current user is the organizer or a juror
  -- whose jury is associated with this voting form.

  -- 1. Check if the user is the organizer.
  --    The join path is: voting_forms -> juries -> contests
  SELECT EXISTS (
    SELECT 1
    FROM public.voting_forms vf
    JOIN public.juries j ON vf.id = j.voting_form_id
    JOIN public.contests c ON j.contest_id = c.id
    WHERE vf.id = p_voting_form_id AND c.organizer_id = auth.uid()
  ) INTO is_organizer;

  -- 2. Check if the user is a juror in a jury that uses this form.
  --    The join path is: voting_forms -> juries -> jurations
  SELECT EXISTS (
    SELECT 1
    FROM public.voting_forms vf
    JOIN public.juries j ON vf.id = j.voting_form_id
    JOIN public.jurations ju ON j.id = ju.jury_id
    WHERE vf.id = p_voting_form_id AND ju.juror_id = auth.uid()
  ) INTO is_juror;

  -- 3. If the user is neither, deny access.
  IF NOT (is_organizer OR is_juror) THEN
    RAISE EXCEPTION 'Voting form not found or access denied.';
  END IF;

  -- If the security check passes, build the bundle.
  SELECT
    jsonb_build_object(
      'voting_form', to_jsonb(vf),
      'voting_form_fields', COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(vff) ORDER BY vff.order_index)
          FROM public.voting_form_fields vff
          WHERE vff.voting_form_id = vf.id
        ),
        '[]'::jsonb
      )
    )
  INTO result_bundle
  FROM public.voting_forms vf
  WHERE vf.id = p_voting_form_id;

  RETURN result_bundle;
END;
$$;