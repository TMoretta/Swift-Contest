-- Schema
GRANT USAGE ON SCHEMA public TO anon,
authenticated,
service_role;

-- Tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO anon,
authenticated,
service_role;

-- Sequences
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO anon,
authenticated,
service_role;

-- Functions (RPC, triggers, ecc.)
GRANT
EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon,
authenticated,
service_role;

grant usage on schema cron to postgres, anon, authenticated, service_role;
grant all privileges on all tables in schema cron to postgres, anon, authenticated, service_role;

-- Grant usage on cron schema
GRANT USAGE ON SCHEMA cron TO postgres, anon, authenticated, service_role;

-- Grant all privileges on tables in cron schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres, anon, authenticated, service_role;

-- Grant all privileges on functions in cron schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA cron TO postgres, anon, authenticated, service_role;

-- Grant execute on specific cron.schedule functions based on identified signatures
GRANT EXECUTE ON FUNCTION cron.schedule(text, text) TO postgres, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION cron.schedule(text, text, text) TO postgres, anon, authenticated, service_role;