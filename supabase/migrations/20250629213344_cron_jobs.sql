CREATE OR REPLACE PROCEDURE update_contests_status()
AS $$
BEGIN
  UPDATE contests
  SET contest_status = CASE
    WHEN now() < works_submission_start THEN
      'preparationPhase'::contest_status
    WHEN now() BETWEEN works_submission_start AND works_submission_end THEN
      'participationPhase'::contest_status
    ELSE
      'votingPhase'::contest_status
  END;
END;
$$ LANGUAGE plpgsql SECURITY definer;


SELECT cron.schedule(
  'update_contests_status',
  '* * * * *',
  $$CALL update_contests_status();$$
);