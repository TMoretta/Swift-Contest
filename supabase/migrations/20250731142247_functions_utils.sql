-- GEN TOKEN
-- GEN TOKEN (Cryptographically Secure)
-- This function generates a secure random token of a given length.
-- It uses the pgcrypto extension for secure random byte generation and avoids
-- ambiguous characters (e.g., I/l/1, O/0) to improve readability.
CREATE OR REPLACE FUNCTION public.gen_token(p_length int)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  token text := '';
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  i int;
  random_byte integer;
BEGIN
  FOR i IN 1..p_length LOOP
    -- get_byte returns an integer from 0-255. We use the modulo operator
    -- to map this to an index in our character set.
    random_byte := get_byte(gen_random_bytes(1), 0);
    token := token || substr(chars, (random_byte % length(chars)) + 1, 1);
  END LOOP;
  RETURN token;
end;
$$;

-- GEN UNIQUE TOKEN
CREATE OR REPLACE FUNCTION gen_unique_token (
  p_table text,
  p_column text,
  p_length int
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  token text;
  token_exists boolean;
  qry text;
BEGIN
  LOOP
    token := gen_token(p_length);
    qry := format('SELECT EXISTS (SELECT 1 FROM %I WHERE %I = $1)', p_table, p_column);
    EXECUTE qry INTO token_exists USING token;
    IF NOT token_exists THEN
      RETURN token;
    END IF;
  END LOOP;
END;
$$;