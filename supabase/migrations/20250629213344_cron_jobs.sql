CREATE OR REPLACE FUNCTION update_contests_status()
RETURNS void AS $$
BEGIN
  UPDATE contests
  SET contest_status = CASE
    WHEN now() < p_contest.works_submission_start THEN
      'preparationPhase'
    WHEN now() BETWEEN p_contest.works_submission_start AND p_contest.works_submission_end THEN
      'participationPhase'
    ELSE
      'votingPhase'
  END
  WHERE contest_status NOT IN ('terminated', 'deleted');
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule(
  'update_contests_status_daily',
  '0 22 * * *',
  $$CALL update_contests_status();$$
);