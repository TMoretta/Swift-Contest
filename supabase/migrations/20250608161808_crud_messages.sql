CREATE OR REPLACE FUNCTION create_message (
  p_message messages
)
RETURNS messages AS $$
DECLARE
  v_message messages;
  v_profile profiles;
BEGIN
  INSERT INTO messages (id, created_at, profile_id, title, body, is_read)
  VALUES (p_message.id, p_message.created_at, p_message.profile_id, p_message.title, p_message.body, p_message.is_read);

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while creating message';
END;
$$ LANGUAGE plpgsql SECURITY definer;

CREATE OR REPLACE FUNCTION get_messages_by_profile_id (
  p_profile_id uuid
)
RETURNS SETOF messages AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM messages
    WHERE profile_id = p_profile_id;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while getting messages';
END;
$$ LANGUAGE plpgsql SECURITY definer;

