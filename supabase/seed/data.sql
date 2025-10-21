-- This script populates the database with a complete, realistic scenario.
-- It assumes that the users have already been created by a separate script (e.g., users.sql).

-- Temporarily disable RLS to allow seeding.
ALTER TABLE public.places DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.juries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_forms DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.participations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.jurations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.works DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_participants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_juries DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_jurors DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_exclusions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_submission_values DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contest_rankings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_fields DISABLE ROW LEVEL SECURITY;

DO $$
DECLARE
  -- 1. GET USER IDs (assuming users.sql has been run)
  v_organizer_id uuid := (SELECT id FROM auth.users WHERE email = 'mario.rossi@example.com');
  v_participant_1_id uuid := (SELECT id FROM auth.users WHERE email = 'luca.bianchi@example.com');
  v_participant_2_id uuid := (SELECT id FROM auth.users WHERE email = 'giovanni.esposito@example.com');
  v_participant_3_id uuid := (SELECT id FROM auth.users WHERE email = 'marco.ricci@example.com');
  v_juror_1_id uuid := (SELECT id FROM auth.users WHERE email = 'andrea.ferri@example.com');
  v_juror_2_id uuid := (SELECT id FROM auth.users WHERE email = 'francesco.gallo@example.com');
  v_juror_3_id uuid := (SELECT id FROM auth.users WHERE email = 'giulia.romano@example.com');
  -- Additional users for more data
  v_simple_juror_1_id uuid := (SELECT id FROM auth.users WHERE email = 'laura.conti@example.com');
  v_simple_juror_2_id uuid := (SELECT id FROM auth.users WHERE email = 'simone.marino@example.com');
  v_organizer_2_id uuid := (SELECT id FROM auth.users WHERE email = 'francesca.leone@example.com');
  v_participant_4_id uuid := (SELECT id FROM auth.users WHERE email = 'alessia.costa@example.com');
  v_participant_5_id uuid := (SELECT id FROM auth.users WHERE email = 'chiara.gatti@example.com');
  v_juror_4_id uuid := (SELECT id FROM auth.users WHERE email = 'elisa.marchetti@example.com');
  v_juror_5_id uuid := (SELECT id FROM auth.users WHERE email = 'federica.monti@example.com');

  -- 2. DEFINE HARDCODED IDs for predictability
  v_contest_id uuid := 'f0f348fd-14c9-4824-9a6c-034100e53a47';
  v_participation_1_id uuid := 'baa38ce9-b61c-4f16-9188-20245d610ec3';
  v_participation_2_id uuid := 'b2c3d4e5-f6a7-b8c9-d0e1-f2a3b4c5d6e7';
  v_participation_3_id uuid := 'c3d4e5f6-a7b8-c9d0-e1f2-a3b4c5d6e7f8';
  v_participation_4_id uuid := '398fa249-edde-4f10-a141-b199ea654af7';
  v_participation_5_id uuid := '5b5381e4-d7a6-4e4f-a963-ac80fd1d8621';
  v_work_1_id uuid := 'c6dcbec9-1e45-4864-8161-fe3ad59555e4';
  v_work_2_id uuid := 'd7a3f48c-ee10-4222-86a8-044034fa8a90';
  v_work_3_id uuid := '53557488-f951-4d5d-8091-46a0a44bf94e';

  -- Other variables
  v_place_id uuid;
  v_appointed_jury_id uuid;
  v_simple_jury_id uuid;
  v_appointed_jury_form_id uuid;
  v_simple_jury_form_id uuid;
  v_juration_1_id uuid;
  v_juration_2_id uuid;
  v_juration_3_id uuid;
  v_juration_4_id uuid;
  v_juration_5_id uuid;
  v_juration_6_id uuid;
  v_voting_session_id uuid;
  v_vs_jury_simple_id uuid;
  v_vs_jury_appointed_id uuid;
  v_vs_juror_1_id uuid;
  v_vs_juror_2_id uuid;
  v_vs_participant_1_id uuid;
  v_vs_participant_2_id uuid;
  v_vs_participant_3_id uuid;
  v_submission_1_id uuid;
  v_submission_3_id uuid;
  v_submission_2_id uuid;
  v_form_field_1_id uuid;
  v_form_field_2_id uuid;

BEGIN
  -- ==================================================
  -- 1. CREATE CONTEST (as Organizer 'mario.rossi')
  -- ==================================================
  INSERT INTO public.places (address, lat, lon) VALUES ('Università di Fisciano, Salerno, Italy', 40.7730, 14.8930) RETURNING id INTO v_place_id;

  -- The image path follows the convention: {contest_id}/{uuid}/{filename}
  -- We assume the file 'header.jpg' is placed in 'supabase/storage/contests-images/11111111-1111-1111-1111-111111111111/'
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths)
  VALUES (v_contest_id, v_organizer_id, 'Fisciano App Design Challenge 2024', 'Una competizione per giovani sviluppatori per progettare la migliore app mobile.', date_trunc('day', now()) + interval '25 days' + interval '10 hours' + interval '15 minutes', now() - interval '1 day', now() + interval '15 days', v_place_id, ARRAY[
    v_contest_id || '/c3989faf-70c5-48a5-adce-6ba36f1c66fb/app_design.png',
    v_contest_id || '/d058e63c-ac1f-42ca-975b-fc07f8553998/app_design.png',
    v_contest_id || '/32190eef-bf3e-4473-a4bf-68b57f30d7f0/app_design.png'
  ]);

  -- ==================================================
  -- 2. CREATE JURIES AND VOTING FORMS
  -- ==================================================
  -- Appointed Jury
  INSERT INTO public.voting_forms (name, description) VALUES ('Valutazione Tecnica App', 'Criteri tecnici per la valutazione di un''applicazione mobile.') RETURNING id INTO v_appointed_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_appointed_jury_form_id, 'Giuria Tecnica', 'appointed') RETURNING id INTO v_appointed_jury_id;
  -- Add more fields to the appointed jury form
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Impressione Generale', 0, 'textual', false, 'header');
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'UI/UX Design', 0, 'slider', 1, 10, true, 'participant') RETURNING id INTO v_form_field_1_id;
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Innovazione', 1, 'slider', 1, 10, true, 'participant');
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Qualità del Codice', 2, 'slider', 1, 10, true, 'participant');
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Feedback per lo sviluppatore', 3, 'textual', false, 'participant');
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Lascia un commento (opzionale)', 0, 'textual', false, 'footer');

  -- Simple Jury
  INSERT INTO public.voting_forms (name, description) VALUES ('Voto del Pubblico', 'Vota la tua app preferita') RETURNING id INTO v_simple_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_simple_jury_form_id, 'Giuria Popolare', 'simple') RETURNING id INTO v_simple_jury_id;
  -- Add more fields to the simple jury form
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_simple_jury_form_id, 'Impressione Generale', 0, 'slider', 1, 5, true, 'participant') RETURNING id INTO v_form_field_2_id;
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_simple_jury_form_id, 'Utilità dell''Idea', 1, 'slider', 1, 5, true, 'participant');
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, is_required, scope) VALUES
    (v_simple_jury_form_id, 'Lascia un commento (opzionale)', 2, 'textual', false, 'participant');

  -- ==================================================
  -- 3. PARTICIPANTS JOIN AND SUBMIT WORKS
  -- ==================================================
  -- Participant 1
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_1_id, v_contest_id, v_participant_1_id, 'luca.bianchi@example.com');
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_1_id, v_participation_1_id, 'SocialConnect App', 'Una nuova app per connettere persone con interessi simili.', ARRAY[v_contest_id || '/' || v_work_1_id || '/1cfb4a21-da86-43c2-835a-3f4480a3940d/image.png', v_contest_id || '/' || v_work_1_id || '/2dfc5b32-eb97-44d3-946b-4g5591b4051e/image.png'], v_contest_id || '/' || v_work_1_id || '/1729fda8-32e6-487c-b12c-1c0ccbf55dc4/project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_1_id;

  -- Participant 2
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_2_id, v_contest_id, v_participant_2_id, 'giovanni.esposito@example.com');
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_2_id, v_participation_2_id, 'FitTrack Pro', 'Un fitness tracker avanzato con gamification.', ARRAY[v_contest_id || '/' || v_work_2_id || '/6737d9e0-2508-432c-a0a5-4702d881185c/image.png'], v_contest_id || '/' || v_work_2_id || '/8dc5097c-9679-4184-9d30-abb8f236c8fa/project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_2_id;

  -- Participant 3
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_3_id, v_contest_id, v_participant_3_id, 'marco.ricci@example.com');
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_3_id, v_participation_3_id, 'RecipeFinder AI', 'Un''app che suggerisce ricette basate sugli ingredienti disponibili.', ARRAY[v_contest_id || '/' || v_work_3_id || '/767d07a7-47f0-4aee-8c29-51772f77011d/image.png', v_contest_id || '/' || v_work_3_id || '/878e18b8-58g1-5bff-9d30-62883g88122e/image.png', v_contest_id || '/' || v_work_3_id || '/989f29c9-69h2-6cgg-ae41-73994h99233f/image.png'], v_contest_id || '/' || v_work_3_id || '/b046cf5a-4b37-447e-aed3-8c2b93044d5d/project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_3_id;
  
  -- Participant 4 (in the same contest)
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_4_id, v_contest_id, v_participant_4_id, 'alessia.costa@example.com');
  -- This participant has not submitted a work yet

  -- ==================================================
  -- 4. JURORS JOIN THE APPOINTED JURY
  -- ==================================================
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, v_juror_1_id, 'andrea.ferri@example.com') RETURNING id INTO v_juration_1_id;
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, v_juror_2_id, 'francesco.gallo@example.com') RETURNING id INTO v_juration_2_id;
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, v_juror_3_id, 'giulia.romano@example.com') RETURNING id INTO v_juration_3_id;
  -- Juror 4 (in the same jury)
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, v_juror_4_id, 'elisa.marchetti@example.com') RETURNING id INTO v_juration_4_id;

  -- ==================================================
  -- 5. ORGANIZER STARTS A VOTING SESSION
  -- ================================================== 
  INSERT INTO public.voting_sessions (name, contest_id, is_geo_restricted, session_status) VALUES ('Votazione', v_contest_id, false, 'ended') RETURNING id INTO v_voting_session_id;

  -- Snapshot participants
  INSERT INTO public.voting_session_participants (voting_session_id, participation_id, order_index, participant_full_name, work_name, work_description, work_images_paths)
  VALUES (v_voting_session_id, v_participation_1_id, 0, 'Luca Bianchi', 'SocialConnect App', 'Una nuova app per connettere persone con interessi simili.', (SELECT images_paths FROM works WHERE id = v_work_1_id))
  RETURNING id INTO v_vs_participant_1_id;

  INSERT INTO public.voting_session_participants (voting_session_id, participation_id, order_index, participant_full_name, work_name, work_description, work_images_paths)
  VALUES (v_voting_session_id, v_participation_2_id, 1, 'Giovanni Esposito', 'FitTrack Pro', 'Un fitness tracker avanzato con gamification.', (SELECT images_paths FROM works WHERE id = v_work_2_id))
  RETURNING id INTO v_vs_participant_2_id;

  INSERT INTO public.voting_session_participants (voting_session_id, participation_id, order_index, participant_full_name, work_name, work_description, work_images_paths)
  VALUES (v_voting_session_id, v_participation_3_id, 2, 'Marco Ricci', 'RecipeFinder AI', 'Un''app che suggerisce ricette basate sugli ingredienti disponibili.', (SELECT images_paths FROM works WHERE id = v_work_3_id))
  RETURNING id INTO v_vs_participant_3_id;
  -- Snapshot juries and jurors
  INSERT INTO public.voting_session_juries (voting_session_id, jury_id, jury_name, jury_type, voting_form_id, jury_token)
  VALUES (v_voting_session_id, v_appointed_jury_id, 'Giuria Tecnica', 'appointed', v_appointed_jury_form_id, 'token123') RETURNING id INTO v_vs_jury_appointed_id;

  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name)
  VALUES
    (v_voting_session_id, v_vs_jury_appointed_id, v_juration_1_id, v_juror_1_id, 'Andrea Ferri')
  RETURNING id INTO v_vs_juror_1_id;

  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name)
  VALUES (v_voting_session_id, v_vs_jury_appointed_id, v_juration_2_id, v_juror_2_id, 'Francesco Gallo')
  RETURNING id INTO v_vs_juror_2_id;  

  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name)
  VALUES (v_voting_session_id, v_vs_jury_appointed_id, v_juration_3_id, v_juror_3_id, 'Giulia Romano')
  RETURNING id INTO v_juration_5_id;

  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name)
  VALUES (v_voting_session_id, v_vs_jury_appointed_id, v_juration_4_id, v_juror_4_id, 'Elisa Marchetti')
  RETURNING id INTO v_juration_6_id;
  -- Add an exclusion (Juror 1 cannot vote for Participant 2)
  INSERT INTO public.voting_session_exclusions (voting_session_id, voting_session_juror_id, voting_session_participant_id)
  VALUES (v_voting_session_id, v_vs_juror_1_id, v_vs_participant_2_id);

  -- ==================================================
  -- 6. JURORS VOTE
  -- ==================================================
  -- Juror 1 votes
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) VALUES (v_voting_session_id, v_vs_juror_1_id) RETURNING id INTO v_submission_1_id;
  INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
  VALUES
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'header' AND order_index = 0), 'Buon livello generale.', NULL),
    (v_submission_1_id, v_form_field_1_id, '8', v_vs_participant_1_id), -- Votes 8 for composition on P1
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), '7', v_vs_participant_1_id), -- Votes 7 for originality on P1
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), '9', v_vs_participant_1_id), -- Votes 9 for tecnica on P1
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 3), 'Molto promettente.', v_vs_participant_1_id),
    (v_submission_1_id, v_form_field_1_id, '6', v_vs_participant_3_id), -- Votes 6 for composition on P3
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), '8', v_vs_participant_3_id), -- Votes 8 for originality on P3
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), '7', v_vs_participant_3_id), -- Votes 7 for tecnica on P3
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'footer' AND order_index = 0), 'Il partecipante 1 è il migliore.', NULL);
  UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = v_vs_juror_1_id;

  -- Juror 2 votes
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) VALUES (v_voting_session_id, v_vs_juror_2_id) RETURNING id INTO v_submission_2_id;
  INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
  VALUES
    (v_submission_2_id, v_form_field_1_id, '7', v_vs_participant_1_id), -- Votes 7 for composition on P1
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), '8', v_vs_participant_1_id), -- Votes 8 for originality on P1
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), '7', v_vs_participant_1_id), -- Votes 7 for tecnica on P1
    (v_submission_2_id, v_form_field_1_id, '9', v_vs_participant_2_id), -- Votes 9 for composition on P2
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), '6', v_vs_participant_2_id), -- Votes 6 for originality on P2
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), '8', v_vs_participant_2_id), -- Votes 8 for tecnica on P2
    (v_submission_2_id, v_form_field_1_id, '5', v_vs_participant_3_id), -- Votes 5 for composition on P3
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), '5', v_vs_participant_3_id), -- Votes 5 for originality on P3
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), '6', v_vs_participant_3_id), -- Votes 6 for tecnica on P3
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 3), 'Potrebbe migliorare.', v_vs_participant_3_id);
  UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = v_vs_juror_2_id;
  
  -- Juror 4 votes
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) VALUES (v_voting_session_id, v_juration_6_id) RETURNING id INTO v_submission_2_id;
  INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
  VALUES
    (v_submission_2_id, v_form_field_1_id, '6', v_vs_participant_1_id),
    (v_submission_2_id, v_form_field_1_id, '8', v_vs_participant_2_id),
    (v_submission_2_id, v_form_field_1_id, '7', v_vs_participant_3_id);
  UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = v_juration_6_id;


  -- ==================================================
  -- 6.5 CREATE AND VOTE IN A SIMPLE JURY SESSION
  -- ==================================================
  -- NOTE: We are using the SAME voting_session_id from the 'Votazione Finale Tecnica'
  -- to add the simple jury to the same session.

  -- Snapshot the simple jury
  INSERT INTO public.voting_session_juries (voting_session_id, jury_id, jury_name, jury_type, voting_form_id, jury_token)
  VALUES (v_voting_session_id, v_simple_jury_id, 'Giuria Studenti', 'simple', v_simple_jury_form_id, 'token456') RETURNING id INTO v_vs_jury_simple_id;

  -- Simple Juror 1 joins and votes
  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juror_id, juror_full_name)
  VALUES (v_voting_session_id, v_vs_jury_simple_id, v_simple_juror_1_id, 'Laura Conti') RETURNING id INTO v_vs_juror_1_id;
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) VALUES (v_voting_session_id, v_vs_juror_1_id) RETURNING id INTO v_submission_1_id;
  INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
  VALUES
    (v_submission_1_id, v_form_field_2_id, '5', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_1_id)),
    (v_submission_1_id, v_form_field_2_id, '4', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_3_id)),
    (v_submission_1_id, v_form_field_2_id, '3', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_2_id)),
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '4', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_1_id)),
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '2', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_2_id)),
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '5', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_3_id)),
    (v_submission_1_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 2), 'Bel lavoro!', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_1_id));
  UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = v_vs_juror_1_id;

  -- Simple Juror 2 joins and votes
  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juror_id, juror_full_name)
  VALUES (v_voting_session_id, v_vs_jury_simple_id, v_simple_juror_2_id, 'Simone Marino') RETURNING id INTO v_vs_juror_2_id;
  INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) VALUES (v_voting_session_id, v_vs_juror_2_id) RETURNING id INTO v_submission_2_id;
  INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
  VALUES 
    (v_submission_2_id, v_form_field_2_id, '4', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_3_id)),
    (v_submission_2_id, v_form_field_2_id, '2', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_1_id)),
    (v_submission_2_id, v_form_field_2_id, '5', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_2_id)),    
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '4', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_1_id)),
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '5', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_2_id)),
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), '3', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_3_id)),
    (v_submission_2_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 2), 'Interessante.', (SELECT id FROM voting_session_participants WHERE voting_session_id = v_voting_session_id AND participation_id = v_participation_3_id));
  UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = v_vs_juror_2_id; 

  -- ==================================================
  -- 7. PUBLISH A RANKING
  -- ==================================================
  INSERT INTO public.contest_rankings (contest_id, file_path) VALUES (v_contest_id, v_contest_id || '/742060eb-1d57-4ba2-856b-559140997b82/final-ranking.pdf');
  
  -- ==================================================
  -- 8. CREATE A SECOND CONTEST
  -- ==================================================
  v_contest_id := '4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d'; -- Use a new hardcoded ID
  INSERT INTO public.places (address, lat, lon) VALUES ('Colosseo, Roma, Italy', 41.8902, 12.4922) RETURNING id INTO v_place_id;
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths)
  VALUES (v_contest_id, v_organizer_id, 'Roma Street Art Fest', 'Un festival dedicato alla street art nella capitale.', date_trunc('day', now()) + interval '50 days' + interval '18 hours' + interval '30 minutes', now(), now() + interval '30 days', v_place_id, ARRAY[
    v_contest_id || '/c9d0e1f2-a3b4-c5d6-e7f8-g9h0i1j2k3l4/street_art.png'
  ]);
  
  -- Add a participant to the new contest
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_5_id, v_contest_id, v_participant_5_id, 'chiara.gatti@example.com');
  
  -- Add a jury to the new contest
  INSERT INTO public.voting_forms (name, description) VALUES ('Valutazione Street Art', 'Criteri per la street art') RETURNING id INTO v_appointed_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_appointed_jury_form_id, 'Giuria Esperti Street Art', 'appointed') RETURNING id INTO v_appointed_jury_id;
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, v_juror_5_id, 'federica.monti@example.com');

  -- ==================================================
  -- 9. CREATE A THIRD CONTEST (also by Mario Rossi)
  -- ==================================================
  v_contest_id := '5b6c7d8e-9f0a-1b2c-3d4e-5f6a7b8c9d0e'; -- Use another new hardcoded ID
  INSERT INTO public.places (address, lat, lon) VALUES ('MAXXI, Roma, Italy', 41.928, 12.466) RETURNING id INTO v_place_id;
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths) VALUES (v_contest_id, v_organizer_id, 'Architettura del Futuro', 'Concorso per giovani architetti.', date_trunc('day', now()) + interval '82 days' + interval '15 hours', now() + interval '10 days', now() + interval '40 days', v_place_id, ARRAY[
    v_contest_id || '/d0e1f2a3-b4c5-d6e7-f8g9-h0i1j2k3l4m5/arch.png'
  ]);
  -- This contest is left intentionally empty (no participants or juries yet) to test a different state.

END $$;

-- Re-enable RLS on all tables
ALTER TABLE public.places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.juries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.participations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jurations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.works ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_juries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_jurors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_session_exclusions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_submission_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contest_rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_form_fields ENABLE ROW LEVEL SECURITY;