CREATE OR REPLACE FUNCTION call_edge_function (
  function text,
  body jsonb,
  service_role_key text
)
RETURNS bigint AS $$
DECLARE
  v_request_id bigint;
BEGIN

  SELECT * INTO v_request_id
  FROM net.http_post(
    url := 'https://sioggqbxhxbnpsahtpkr.supabase.co/functions/v1/' || function,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_role_key
    ),
    body := body
  );

  RETURN v_request_id;
END;
$$ LANGUAGE plpgsql SECURITY definer;
