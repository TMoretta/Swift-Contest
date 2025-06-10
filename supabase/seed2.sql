INSERT INTO auth.users ( instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
  ('00000000-0000-0000-0000-000000000000', '23e0467d-de10-49dd-a0f5-05ef4006e2eb', 'authenticated', 'authenticated', 'organizer1@example.com', crypt('password', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '');


-- test user email identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES
  (uuid_generate_v4(), (SELECT id FROM auth.users WHERE email = 'organizer1@example.com'), format('{"sub":"%s","email":"%s"}', (SELECT id FROM auth.users WHERE email = 'organizer1@example.com')::text, 'organizer1@example.com')::jsonb, 'email', uuid_generate_v4(), now(), now(), now());


--INSERT INTO
--auth.users (
--    instance_id,
--    id,
--    aud,
--    role,
--    email,
--    encrypted_password,
--    email_confirmed_at,
--    recovery_sent_at,
--    last_sign_in_at,
--    raw_app_meta_data,
--    raw_user_meta_data,
--    created_at,
--    updated_at,
--    confirmation_token,
--    email_change,
--    email_change_token_new,
--    recovery_token
--) (
--    select
--        '00000000-0000-0000-0000-000000000000',
--        '8424bb1b-4176-4795-9610-86f8b2aba39e',
--        'authenticated',
--        'authenticated',
--        'organizer1@example.com',
--        crypt ('123456', gen_salt ('bf')),
--        now(),
--        now(),
--        now(),
--        '{"provider":"email","providers":["email"]}',
--        '{}',
--        now(),
--        now(),
--        '',
--        '',
--        '',
--        ''
--    FROM
--        generate_series(1, 10)
--);
--
---- test user email identities
--INSERT INTO
--auth.identities (
--    id,
--    user_id,
--    identity_data,
--    provider,
--    last_sign_in_at,
--    created_at,
--    updated_at
--) (
--    select
--        uuid_generate_v4 (),
--        id,
--        format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
--        'email',
--        now(),
--        now(),
--        now()
--    from
--        auth.users
--    where
--      email LIKE '%@example.com'
--);

INSERT INTO public.profiles (id,created_at,full_name,pref_theme,pref_contest_role,is_deleted)
VALUES ('23e0467d-de10-49dd-a0f5-05ef4006e2eb',now(),'Organizer1','dark','organizer','false');