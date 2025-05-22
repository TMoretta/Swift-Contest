-- CREATE PARTICIPATION
CREATE OR REPLACE FUNCTION public.create_participation (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_participant_id uuid,
  p_participant_status public.participant_status,
  p_work_status public.work_status
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
    INSERT INTO public.participations (
      id,
      created_at,
      contest_id,
      participant_id,
      participant_status,
      work_status
    )
    VALUES (
      p_id,
      p_created_at,
      p_contest_id,
      p_participant_id,
      p_participant_status,
      p_work_status
    )
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- UPDATE PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION public.update_participation (
  p_id uuid,
  p_created_at timestamptz,
  p_contest_id uuid,
  p_participant_id uuid,
  p_participant_status public.participant_status,
  p_work_status public.work_status
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
    UPDATE public.participations
    SET
      created_at = p_created_at,
      contest_id = p_contest_id,
      participant_id = p_participant_id,
      participant_status = p_participant_status,
      work_status = p_work_status
    WHERE id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- DELETE PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION public.delete_participation_by_id(
  p_id uuid
)
RETURNS void AS $$
BEGIN
  DELETE FROM public.participations
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATION BY ID
CREATE OR REPLACE FUNCTION public.get_participation_by_id(
  p_id uuid
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.participations
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATION BY CONTEST ID AND PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_participation_by_contest_id_and_participant_id(
  p_contest_id uuid,
  p_participant_id uuid
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM public.participations
    WHERE contest_id = p_contest_id AND participant_id = p_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATIONS BY CONTEST ID
CREATE OR REPLACE FUNCTION public.get_participations_by_contest_id(
  p_contest_id uuid
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.participations
  WHERE contest_id = p_contest_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET PARTICIPATIONS BY PARTICIPANT ID
CREATE OR REPLACE FUNCTION public.get_participations_by_participant_id(
  p_participant_id uuid
)
RETURNS SETOF public.participations AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.participations
  WHERE participant_id = p_participant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;