-- CREATE VOTING SESSION PARTICIPANT
CREATE OR REPLACE FUNCTION public.create_voting_session_participant (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_participant_id uuid,
  p_order_index integer
)
RETURNS SETOF public.voting_session_participants AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.voting_session_participants (
      id,
      created_at,
      voting_session_id,
      participant_id,
      order_index
    )
    VALUES (
      p_id,
      p_created_at,
      p_voting_session_id,
      p_participant_id,
      p_order_index
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE VOTING SESSION PARTICIPANT BY ID
CREATE OR REPLACE FUNCTION public.update_voting_session_participant (
  p_id uuid,
  p_created_at timestamptz,
  p_voting_session_id uuid,
  p_participant_id uuid,
  p_order_index integer
)
RETURNS SETOF public.voting_session_participants AS $$
BEGIN
  RETURN QUERY
    UPDATE public.voting_session_participants
    SET
      created_at = p_created_at,
      voting_session_id = p_voting_session_id,
      participant_id = p_participant_id,
      order_index = p_order_index
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE VOTING SESSION PARTICIPANT BY ID
CREATE OR REPLACE FUNCTION public.delete_voting_session_participant_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.voting_session_participants
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPANT BY ID
CREATE OR REPLACE FUNCTION public.get_voting_session_participant_by_id(
  p_id uuid
)
RETURNS SETOF public.voting_session_participants AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_session_participants
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPANT BY VOTING SESSION ID AND PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_voting_session_participant_by_voting_session_id_and_participant_id(
  p_voting_session_id uuid,
  p_participant_id uuid
)
RETURNS SETOF public.voting_session_participants AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.voting_session_participants
    WHERE voting_session_id = p_voting_session_id AND participant_id = p_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION PARTICIPANTS BY VOTING SESSION ID
CREATE OR REPLACE FUNCTION public.get_voting_session_participants_by_voting_session_id(
  p_voting_session_id uuid
)
RETURNS SETOF public.voting_session_participants AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.voting_session_participants
  WHERE voting_session_id = p_voting_session_id
  ORDER BY order_index; -- Added ORDER BY for consistency
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;