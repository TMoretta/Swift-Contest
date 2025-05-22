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