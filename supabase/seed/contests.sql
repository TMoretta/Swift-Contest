-- PLACES
INSERT INTO public.places (id,created_at,address,lat,lon)
VALUES ('895d8f1d-5844-42e2-96e8-c49e6c5e076a',now(),'Vietnam','14.058324','108.277199');

-- VOTING FORMS
INSERT INTO public.voting_forms (id,created_at)
VALUES ('ac2979f1-aa67-496d-941c-16f97850ae10',now());

-- VOTING FORM FIELDS
INSERT INTO public.voting_form_fields (
  id,
  created_at,
  voting_form_id,
  name,
  order_index,
  min_value,
  max_value
)
VALUES (
  'e0fa2dc8-5e8e-4b69-b660-dc117b46b8fa',
  now(),
  'ac2979f1-aa67-496d-941c-16f97850ae10',
  'Field 1',
  0,
  0,
  10
);

INSERT INTO public.voting_form_fields (
  id,
  created_at,
  voting_form_id,
  name,
  order_index,
  min_value,
  max_value
)
VALUES (
  'e3cb7cb4-4812-4e01-81ae-3c84425699a0',
  now(),
  'ac2979f1-aa67-496d-941c-16f97850ae10',
  'Field 2',
  1,
  0,
  10
);

INSERT INTO public.voting_form_fields (
  id,
  created_at,
  voting_form_id,
  name,
  order_index,
  min_value,
  max_value
)
VALUES (
  '350e6ba3-be7b-4026-a03b-1811b6f8508b',
  now(),
  'ac2979f1-aa67-496d-941c-16f97850ae10',
  'Field 3',
  2,
  0,
  10
);

-- CONTESTS
INSERT INTO public.contests (
  id,
  created_at,
  organizer_id,
  name,
  description,
  date_time,
  works_submission_start,
  works_submission_end,
  place_id,
  contest_status,
  images_urls,
  token,
  voting_form_id
)
VALUES (
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  now(),
  (SELECT id FROM auth.users WHERE email = 'organizer1@example.com'),
  'Contest 1',
  'A simple contest for testing the app.',
  '2025-05-30 15:00:00+00',
  '2025-05-21 15:00:00+00',
  '2025-05-28 15:00:00+00',
  '895d8f1d-5844-42e2-96e8-c49e6c5e076a',
  'preparationPhase',
  ARRAY['https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/contests-images//image1.jpeg','https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/contests-images//image2.jpeg'],
  'c1c1c1c1c1c1c1',
  'ac2979f1-aa67-496d-941c-16f97850ae10'
);

-- INVITATIONS
INSERT INTO public.invitations (
  id,
  created_at,
  contest_id,
  token,
  email,
  member_role
)
VALUES (
  '4e541e20-de48-4543-b9f8-f47226e71b44',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  'p4p4p4p4p4p4p4',
  'participant4@example.com',
  'participant'
);

INSERT INTO public.invitations (
  id,
  created_at,
  contest_id,
  token,
  email,
  member_role
)
VALUES (
  'bd11b3dc-d32d-45fb-a3b1-0fe34488e598',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  'p5p5p5p5p5p5p5',
  'participant5@example.com',
  'participant'
);

INSERT INTO public.invitations (
  id,
  created_at,
  contest_id,
  token,
  email,
  member_role
)
VALUES (
  '6d9f447e-338d-4fe8-b0f5-44e7341c79b9',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  'j4j4j4j4j4j4j4',
  'juror4@example.com',
  'juror'
);

INSERT INTO public.invitations (
  id,
  created_at,
  contest_id,
  token,
  email,
  member_role
)
VALUES (
  'c073ffd1-ad81-4027-b46c-1e2e1a19ee42',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  'j5j5j5j5j5j5j5',
  'juror5@example.com',
  'juror'
);

-- PARTICIPATIONS
INSERT INTO public.participations (
  id,
  created_at,
  contest_id,
  participant_id,
  participant_status,
  invitation_email,
  has_submitted
)
VALUES (
  '4970aafd-11b8-4098-a508-8fe0c99c62d8',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  (SELECT id FROM auth.users WHERE email = 'participant1@example.com'),
  'joined',
  'participant1@example.com',
  true
);

INSERT INTO public.participations (
  id,
  created_at,
  contest_id,
  participant_id,
  participant_status,
  invitation_email,
  has_submitted
)
VALUES (
  '8f284b92-619a-410a-a6c1-e9d389c1e032',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  (SELECT id FROM auth.users WHERE email = 'participant2@example.com'),
  'joined',
  'participant2@example.com',
  true
);

INSERT INTO public.participations (
  id,
  created_at,
  contest_id,
  participant_id,
  participant_status,
  invitation_email,
  has_submitted
)
VALUES (
  '89c64c56-7d17-420b-9444-1b9ae3716f0a',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  (SELECT id FROM auth.users WHERE email = 'participant3@example.com'),
  'out',
  'participant3@example.com',
  true
);

-- JURATIONS
INSERT INTO public.jurations (
  id,
  created_at,
  contest_id,
  juror_id,
  juror_status,
  invitation_email
)
VALUES (
  '1c3e0f2e-0691-479e-8fb1-aee4c5449f86',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  (SELECT id FROM auth.users WHERE email = 'juror1@example.com'),
  'joined',
  'juror1@example.com'
);

INSERT INTO public.jurations (
  id,
  created_at,
  contest_id,
  juror_id,
  juror_status,
  invitation_email
)
VALUES (
  '6c78e4df-e1e1-4bd0-9d74-ec701b962d9c',
  now(),
  'e9ecc1b3-beee-47ca-a55d-c691a1503f35',
  (SELECT id FROM auth.users WHERE email = 'juror2@example.com'),
  'joined',
  'juror2@example.com'
);

-- WORKS
INSERT INTO public.works (
  id,
  created_at,
  participation_id,
  name,
  description,
  images_urls,
  file_url
)
VALUES (
  '3fa25e47-7c98-43c8-b055-496247ff837b',
  now(),
  '4970aafd-11b8-4098-a508-8fe0c99c62d8',
  'Work 1',
  'sd dsf sadfweu dujfhe eurh dfet dfgg sdafe.',
  ARRAY['https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-images//image3.jpeg'],
  'https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-files//file1.pdf'
);

INSERT INTO public.works (
  id,
  created_at,
  participation_id,
  name,
  description,
  images_urls,
  file_url
)
VALUES (
  'bd980b01-f2d1-42ff-9cb1-ad3745bc0488',
  now(),
  '8f284b92-619a-410a-a6c1-e9d389c1e032',
  'Work 2',
  'sd dsf sadfweu dujfhe eurh dfet dfgg sdafe.',
  ARRAY['https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-images//image4.jpeg'],
  'https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-files//file1.pdf'
);

INSERT INTO public.works (
  id,
  created_at,
  participation_id,
  name,
  description,
  images_urls,
  file_url
)
VALUES (
  '351c5636-808c-49fe-bbe3-4e8daf0e29e5',
  now(),
  '89c64c56-7d17-420b-9444-1b9ae3716f0a',
  'Work 2',
  'sd dsf sadfweu dujfhe eurh dfet dfgg sdafe.',
  ARRAY['https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-images//image1.jpeg'],
  'https://sioggqbxhxbnpsahtpkr.supabase.co/storage/v1/object/public/works-files//file1.pdf'
);