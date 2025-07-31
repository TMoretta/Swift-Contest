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