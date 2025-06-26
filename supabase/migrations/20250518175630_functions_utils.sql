-- GEN TOKEN
CREATE OR REPLACE FUNCTION gen_token (n int)
RETURNS text AS $$
DECLARE
  token text := '';
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
  i int;
BEGIN
  FOR i IN 1..n LOOP
    token := token || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN token;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while generating the token';
end;
$$ LANGUAGE plpgsql SECURITY definer;

-- GEN UNIQUE TOKEN
CREATE OR REPLACE FUNCTION gen_unique_token (
  p_table text,
  p_column text,
  p_length int
)
RETURNS text AS $$
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

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An error occurred while generating the token';
END;
$$ LANGUAGE plpgsql SECURITY definer;