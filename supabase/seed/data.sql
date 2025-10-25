-- This script populates the database with a complete, realistic scenario.
-- It assumes that the users have already been created by a separate script (e.g., users.sql).

DO $$
DECLARE
  -- 1. GET USER IDs (assuming users.sql has been run)
  v_organizer_id uuid := (SELECT id FROM auth.users WHERE email = 'mario.rossi@example.com');

  -- Participants (10)
  participants_ids uuid[] := ARRAY[
    (SELECT id FROM auth.users WHERE email = 'luca.bianchi@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giovanni.esposito@example.com'),
    (SELECT id FROM auth.users WHERE email = 'marco.ricci@example.com'),
    (SELECT id FROM auth.users WHERE email = 'alessia.costa@example.com'),
    (SELECT id FROM auth.users WHERE email = 'chiara.gatti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'laura.conti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'simone.marino@example.com'),
    (SELECT id FROM auth.users WHERE email = 'valentina.rizzo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'davide.moretti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'sara.barbieri@example.com')
  ];

  -- Technical Jurors (25)
  technical_jurors_ids uuid[] := ARRAY[
    (SELECT id FROM auth.users WHERE email = 'andrea.ferri@example.com'),
    (SELECT id FROM auth.users WHERE email = 'francesco.gallo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giulia.romano@example.com'),
    (SELECT id FROM auth.users WHERE email = 'francesca.leone@example.com'),
    (SELECT id FROM auth.users WHERE email = 'elisa.marchetti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'federica.monti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'matteo.fontana@example.com'),
    (SELECT id FROM auth.users WHERE email = 'elena.greco@example.com'),
    (SELECT id FROM auth.users WHERE email = 'riccardo.deluca@example.com'),
    (SELECT id FROM auth.users WHERE email = 'sofia.ferrari@example.com'),
    (SELECT id FROM auth.users WHERE email = 'alessandro.russo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'martina.colombo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'lorenzo.galli@example.com'),
    (SELECT id FROM auth.users WHERE email = 'beatrice.marino@example.com'),
    (SELECT id FROM auth.users WHERE email = 'gabriele.greco@example.com'),
    (SELECT id FROM auth.users WHERE email = 'anna.santoro@example.com'),
    (SELECT id FROM auth.users WHERE email = 'leonardo.lombardi@example.com'),
    (SELECT id FROM auth.users WHERE email = 'aurora.rizzi@example.com'),
    (SELECT id FROM auth.users WHERE email = 'filippo.bruno@example.com'),
    (SELECT id FROM auth.users WHERE email = 'ginevra.moretti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'tommaso.serra@example.com'),
    (SELECT id FROM auth.users WHERE email = 'ludovica.conti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'edoardo.deangelis@example.com'),
    (SELECT id FROM auth.users WHERE email = 'caterina.mazza@example.com'),
    (SELECT id FROM auth.users WHERE email = 'samuele.martini@example.com')
  ];

  -- Simple Jurors (Students) (14)
  simple_jurors_ids uuid[] := ARRAY[
    (SELECT id FROM auth.users WHERE email = 'vittoria.gentile@example.com'),
    (SELECT id FROM auth.users WHERE email = 'diego.ferretti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'emma.palumbo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'nicolo.basile@example.com'),
    (SELECT id FROM auth.users WHERE email = 'alice.damico@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giacomo.fiore@example.com'),
    (SELECT id FROM auth.users WHERE email = 'greta.longo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'christian.pellegrini@example.com'),
    (SELECT id FROM auth.users WHERE email = 'bianca.coppola@example.com'),
    (SELECT id FROM auth.users WHERE email = 'michele.amato@example.com'),
    (SELECT id FROM auth.users WHERE email = 'irene.ferrara@example.com'),
    (SELECT id FROM auth.users WHERE email = 'daniele.vitali@example.com'),
    (SELECT id FROM auth.users WHERE email = 'camilla.rinaldi@example.com'),
    (SELECT id FROM auth.users WHERE email = 'roberto.bianco@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giorgia.marini@example.com'),
    (SELECT id FROM auth.users WHERE email = 'paolo.de_rosa@example.com'),
    (SELECT id FROM auth.users WHERE email = 'serena.rizzo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'antonio.lombardo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'claudia.moretti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'emanuele.barone@example.com'),
    (SELECT id FROM auth.users WHERE email = 'noemi.palmieri@example.com'),
    (SELECT id FROM auth.users WHERE email = 'simona.longo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'vincenzo.santoro@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giada.martinelli@example.com'),
    (SELECT id FROM auth.users WHERE email = 'gabriella.serra@example.com'),
    (SELECT id FROM auth.users WHERE email = 'salvatore.conte@example.com'),
    (SELECT id FROM auth.users WHERE email = 'rosa.marchetti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'domenico.ferri@example.com'),
    (SELECT id FROM auth.users WHERE email = 'cristina.galli@example.com'),
    (SELECT id FROM auth.users WHERE email = 'angelo.russo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'veronica.ferrari@example.com'),
    (SELECT id FROM auth.users WHERE email = 'giuseppe.esposito@example.com'),
    (SELECT id FROM auth.users WHERE email = 'maria.bianchi@example.com'),
    (SELECT id FROM auth.users WHERE email = 'alberto.romano@example.com'),
    (SELECT id FROM auth.users WHERE email = 'eleonora.gallo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'riccardo.martini@example.com'),
    (SELECT id FROM auth.users WHERE email = 'barbara.leone@example.com'),
    (SELECT id FROM auth.users WHERE email = 'fabio.costa@example.com'),
    (SELECT id FROM auth.users WHERE email = 'silvia.gatti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'massimo.ferretti@example.com'),
    (SELECT id FROM auth.users WHERE email = 'daniela.palumbo@example.com'),
    (SELECT id FROM auth.users WHERE email = 'stefano.basile@example.com')
  ];

  -- 2. DEFINE HARDCODED IDs for predictability
  v_contest_id uuid := 'f0f348fd-14c9-4824-9a6c-034100e53a47';

  -- Hardcoded IDs for participations and works
  v_participation_ids uuid[] := ARRAY[
    'c6dcbec9-1e45-4864-8161-fe3ad59555e4', 'd7a3f48c-ee10-4222-86a8-044034fa8a90',
    '53557488-f951-4d5d-8091-46a0a44bf94e', '89b3c1a4-2e5d-4f8b-8c1a-3d9e4f7b1a2c',
    '9ac4d2b5-3f6e-4a9c-9d2b-4e0f5a8c2b3d', '25debe75-a68f-4cb0-9cc5-8496a0bb7543',
    'be6f4d7a-5b8a-4c1b-b14d-6a2b7cae4d5f', 'cf7a5e8b-6c9b-4d2c-c25e-7b3c8dbf5e6a',
    '0618735d-c501-46e9-b3b6-6bd78473a6b9', 'e315f513-878d-4a8d-8aa3-1377e0cbe46f'
  ];
  v_work_ids uuid[] := ARRAY[
    '1aa2bb3c-4dd5-ee6f-7aa8-bb9cc0dd1ee2', '2bb3cc4d-5ee6-ff7a-8bb9-cc0dd1ee2ff3',
    '3cc4dd5e-6ff7-aa8b-9cc0-dd1ee2ff3aa4', '4dd5ee6f-7aa8-bb9c-c0dd-1ee2ff3aa4bb',
    '5ee6ff7a-8bb9-cc0d-d1ee-2ff3aa4bb5cc', '6ff7aa8b-9cc0-dd1e-e2ff-3aa4bb5cc6dd',
    'b83655bc-ccf0-4b8f-97b5-34a12316e30d', '5d115f94-668a-459f-b7ae-466320c14537',
    'ab8c3b47-62f7-40c8-b5ff-9e0b8364a212', '3dd0c49c-d80a-49ff-987c-3125b933bbbc'
  ];

  -- Other variables
  v_place_id uuid;
  v_appointed_jury_id uuid;
  v_simple_jury_id uuid;
  v_appointed_jury_form_id uuid;
  v_simple_jury_form_id uuid;
  v_juration_1_id uuid;
  v_juration_2_id uuid;
  v_juration_3_id uuid;
  v_voting_session_id uuid;
  v_vs_jury_simple_id uuid;
  v_vs_jury_appointed_id uuid;
  v_vs_juror_1_id uuid;
  v_vs_juror_2_id uuid;
  v_vs_simple_juror_1_id uuid;
  v_vs_simple_juror_2_id uuid;
  v_vs_participant_1_id uuid;
  v_vs_participant_2_id uuid;
  v_submission_1_id uuid;
  v_submission_3_id uuid;
  v_submission_2_id uuid;
  v_form_field_1_id uuid;
  v_form_field_2_id uuid;

BEGIN

  --region CREATE CONTEST (by Mario Rossi)
  INSERT INTO public.places (address, lat, lon) VALUES ('Università degli Studi di Salerno, Fisciano, SA, Italy', 40.7730, 14.8930) RETURNING id INTO v_place_id;

  -- The image path follows the convention: {contest_id}/{uuid}/{filename}
  -- We assume the file 'header.jpg' is placed in 'supabase/storage/contests-images/11111111-1111-1111-1111-111111111111/'
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths)
  VALUES (v_contest_id, v_organizer_id, 'Fisciano App Design Challenge 2025', 'Una competizione per giovani sviluppatori per progettare la migliore app mobile.', '2025-03-20 14:00:00+00', '2025-03-01 23:00:00+00', '2025-03-15 23:00:00+00', v_place_id, ARRAY[
    'fisciano_app_design_1.png',
    'fisciano_app_design_2.png'
  ]);

  -- ==================================================
  --CREATE JURIES AND VOTING FORMS
  -- Appointed Jury
  INSERT INTO public.voting_forms (name, description) VALUES ('Valutazione Tecnica App', 'Criteri tecnici per la valutazione di un''applicazione mobile.') RETURNING id INTO v_appointed_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_appointed_jury_form_id, 'Giuria Tecnica', 'appointed') RETURNING id INTO v_appointed_jury_id;
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_appointed_jury_form_id, 'Nome e cognome', 0, 'textual', null, null, true, 'header'),
    (v_appointed_jury_form_id, 'Ruolo professionale / area di competenza (UI Designer, Developer, UX Researcher, Project Manager, ecc.)', 1, 'textual', null, null, false, 'header'),
    (v_appointed_jury_form_id, 'UI/UX Design', 0, 'slider', 1, 10, true, 'participant'),
    (v_appointed_jury_form_id, 'Innovazione', 1, 'slider', 1, 10, true, 'participant'),
    (v_appointed_jury_form_id, 'Qualità del Codice', 2, 'slider', 1, 10, true, 'participant'),
    (v_appointed_jury_form_id, 'Stabilità e Performance', 3, 'slider', 1, 10, true, 'participant'),
    (v_appointed_jury_form_id, 'Voto Complessivo Finale', 4, 'slider', 1, 10, true, 'participant'),
    (v_appointed_jury_form_id, 'Feedback per lo sviluppatore', 5, 'textual', null, null, false, 'participant'),
    (v_appointed_jury_form_id, 'Livello generale dei progetti visti', 0, 'slider', 1, 5, true, 'footer'),
    (v_appointed_jury_form_id, 'Valutazione complessiva dell''esperienza', 1, 'slider', 1, 10, true, 'footer'),
    (v_appointed_jury_form_id, 'Suggerimenti per le prossime edizioni', 2, 'textual', null, null, false, 'footer');

  -- Simple Jury
  INSERT INTO public.voting_forms (name, description) VALUES ('Voto degli studenti', 'Vota la tua app preferita') RETURNING id INTO v_simple_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_simple_jury_form_id, 'Giuria Studenti', 'simple') RETURNING id INTO v_simple_jury_id;
  INSERT INTO public.voting_form_fields (voting_form_id, question, order_index, type, slider_min_value, slider_max_value, is_required, scope) VALUES
    (v_simple_jury_form_id, 'Nome e cognome', 0, 'textual', null, null, true, 'header'),
    (v_simple_jury_form_id, 'Corso di laurea', 1, 'textual', null, null, true, 'header'),
    (v_simple_jury_form_id, 'Anno di studio', 2, 'textual', null, null, true, 'header'),
    (v_simple_jury_form_id, 'Utilità', 0, 'slider', 1, 5, true, 'participant'),
    (v_simple_jury_form_id, 'Facilità d''Uso', 1, 'slider', 1, 5, true, 'participant'),
    (v_simple_jury_form_id, 'Originalità dell’idea', 2, 'slider', 1, 5, true, 'participant'),
    (v_simple_jury_form_id, 'Valutazione complessiva dell’esperienza', 0, 'slider', 1, 10, true, 'footer'),
    (v_simple_jury_form_id, 'Parteciperesti di nuovo?', 1, 'textual', null, null, true, 'footer'),
    (v_simple_jury_form_id, 'Hai suggerimenti per migliorarlo?', 2, 'textual', null, null, false, 'footer');


  -- ==================================================
  -- PARTICIPANTS JOIN AND SUBMIT WORKS
  -- Participant 1
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[1], v_contest_id, participants_ids[1], (SELECT email FROM auth.users WHERE id = participants_ids[1]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[1], v_participation_ids[1], 'RecipeFinder AI', 'RecipeFinder AI è il tuo assistente da cucina intelligente che trasforma gli ingredienti che hai già in deliziose ricette facili da seguire. Scansiona il tuo frigo o la tua dispensa e lascia che la nostra IA trovi il pasto perfetto per te, riducendo gli sprechi alimentari e ispirando lo chef che è in te.', ARRAY['recipe_finder_ai_1.png','recipe_finder_ai_2.png','recipe_finder_ai_3.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[1];

  -- Participant 2
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[2], v_contest_id, participants_ids[2], (SELECT email FROM auth.users WHERE id = participants_ids[2]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[2], v_participation_ids[2], 'SalernoGo', 'Guida turistica interattiva per la città di Salerno.', ARRAY['salerno_go.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[2];

  -- Participant 3
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[3], v_contest_id, participants_ids[3], (SELECT email FROM auth.users WHERE id = participants_ids[3]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[3], v_participation_ids[3], 'UniConnect', 'Social network per studenti universitari.', ARRAY['uni_connect.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[3];

  -- Participant 4
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[4], v_contest_id, participants_ids[4], (SELECT email FROM auth.users WHERE id = participants_ids[4]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[4], v_participation_ids[4], 'FitCampus', 'App per il fitness pensata per la vita universitaria.', ARRAY['fit_campus.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[4];

  -- Participant 5
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[5], v_contest_id, participants_ids[5], (SELECT email FROM auth.users WHERE id = participants_ids[5]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[5], v_participation_ids[5], 'StudyBuddy AI', 'Assistente allo studio basato su AI.', ARRAY['study_buddy_ai.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[5];

  -- Participant 6
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[6], v_contest_id, participants_ids[6], (SELECT email FROM auth.users WHERE id = participants_ids[6]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[6], v_participation_ids[6], 'EventHive', 'Scopri eventi locali e concerti.', ARRAY['event_hive.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[6];

  -- Participant 7
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[7], v_contest_id, participants_ids[7], (SELECT email FROM auth.users WHERE id = participants_ids[7]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[7], v_participation_ids[7], 'GreenRoute', 'Navigatore eco-friendly per percorsi a piedi e in bici.', ARRAY['green_route.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[7];

  -- Participant 8
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[8], v_contest_id, participants_ids[8], (SELECT email FROM auth.users WHERE id = participants_ids[8]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[8], v_participation_ids[8], 'ArtQuest', 'App gamificata per imparare la storia dell''arte.', ARRAY['art_quest.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[8];

  -- Participant 9
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[9], v_contest_id, participants_ids[9], (SELECT email FROM auth.users WHERE id = participants_ids[9]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[9], v_participation_ids[9], 'CodeLeap', 'Piattaforma per imparare a programmare con sfide interattive.', ARRAY['code_leap.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[9];

  -- Participant 10
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (v_participation_ids[10], v_contest_id, participants_ids[10], (SELECT email FROM auth.users WHERE id = participants_ids[10]));
  INSERT INTO public.works (id, participation_id, name, description, images_paths, file_path) VALUES (v_work_ids[10], v_participation_ids[10], 'MindWell', 'App per la meditazione e il benessere mentale.', ARRAY['mind_well.png'],'project.zip');
  UPDATE public.participations SET has_submitted = true WHERE id = v_participation_ids[10];

  -- ==================================================
  -- 4. JURORS JOIN THE APPOINTED JURY
  -- ==================================================
  FOR i IN 1..array_length(technical_jurors_ids, 1) LOOP
    INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, technical_jurors_ids[i], (SELECT email FROM auth.users WHERE id = technical_jurors_ids[i]));
  END LOOP;

  -- ==================================================
  -- 5. ORGANIZER STARTS A VOTING SESSION
  -- ==================================================
  INSERT INTO public.voting_sessions (name, contest_id, is_geo_restricted, session_status) VALUES ('Votazione', v_contest_id, false, 'ended') RETURNING id INTO v_voting_session_id;

  -- Snapshot all 10 participants
  INSERT INTO public.voting_session_participants (voting_session_id, participation_id, order_index, participant_full_name, work_name, work_description, work_images_paths)
  SELECT
    v_voting_session_id,
    p.id,
    row_number() OVER (ORDER BY p.created_at) - 1,
    pr.full_name,
    w.name,
    w.description,
    w.images_paths
  FROM public.participations p
  JOIN public.profiles pr ON p.participant_id = pr.id
  JOIN public.works w ON p.id = w.participation_id
  WHERE p.contest_id = v_contest_id AND p.has_submitted = true;

  -- Snapshot both juries
  INSERT INTO public.voting_session_juries (voting_session_id, jury_id, jury_name, jury_type, voting_form_id, jury_token)
  VALUES
    (v_voting_session_id, v_appointed_jury_id, 'Giuria Tecnica', 'appointed', v_appointed_jury_form_id, 'token123'),
    (v_voting_session_id, v_simple_jury_id, 'Giuria Studenti', 'simple', v_simple_jury_form_id, 'token456');

  -- Get the new snapshot jury IDs
  SELECT id INTO v_vs_jury_appointed_id FROM public.voting_session_juries WHERE voting_session_id = v_voting_session_id AND jury_id = v_appointed_jury_id;
  SELECT id INTO v_vs_jury_simple_id FROM public.voting_session_juries WHERE voting_session_id = v_voting_session_id AND jury_id = v_simple_jury_id;

  -- Snapshot all technical jurors
  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juration_id, juror_id, juror_full_name)
  SELECT
    v_voting_session_id,
    v_vs_jury_appointed_id,
    j.id,
    j.juror_id,
    p.full_name
  FROM public.jurations j
  JOIN public.profiles p ON j.juror_id = p.id
  WHERE j.jury_id = v_appointed_jury_id;

  -- Snapshot all simple jurors
  INSERT INTO public.voting_session_jurors (voting_session_id, voting_session_jury_id, juror_id, juror_full_name)
  SELECT
    v_voting_session_id,
    v_vs_jury_simple_id,
    u.id,
    p.full_name
  FROM unnest(simple_jurors_ids) AS u_id
  JOIN auth.users u ON u.id = u_id
  JOIN public.profiles p ON u.id = p.id;

  -- ==================================================
  -- 6. SOME JURORS VOTE
  -- ==================================================
  
  -- Loop through the first 24 technical jurors to submit their votes
  FOR i IN 1..24 LOOP
    DECLARE
      juror_snapshot_id uuid;
      submission_id uuid;
    BEGIN
      -- Get the snapshot ID for the current juror
      SELECT id INTO juror_snapshot_id FROM public.voting_session_jurors 
      WHERE juror_id = technical_jurors_ids[i] AND voting_session_id = v_voting_session_id;

      -- Create a submission record
      INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) 
      VALUES (v_voting_session_id, juror_snapshot_id) RETURNING id INTO submission_id;

      -- Insert header votes
      INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value)
      VALUES
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'header' AND order_index = 0), (SELECT full_name FROM profiles WHERE id = technical_jurors_ids[i])),
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'header' AND order_index = 1), 'Senior Developer');

      -- Insert participant votes for all 10 participants
      FOR p_idx IN 1..10 LOOP
        INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
        VALUES
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 0), floor(random() * 10 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 1), floor(random() * 10 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 2), floor(random() * 10 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 3), floor(random() * 10 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 4), floor(random() * 10 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'participant' AND order_index = 5), 'Feedback di test per il partecipante ' || p_idx, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx]));
      END LOOP;

      -- Insert footer votes
      INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value)
      VALUES
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'footer' AND order_index = 0), floor(random() * 5 + 1)::text),
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_appointed_jury_form_id AND scope = 'footer' AND order_index = 1), floor(random() * 10 + 1)::text);

      -- Mark juror as submitted
      UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = juror_snapshot_id;
    END;
  END LOOP;

  -- Loop through the simple jurors to submit their votes (leaving 6 out)
  FOR i IN 1..(array_length(simple_jurors_ids, 1) - 6) LOOP
    DECLARE
      juror_snapshot_id uuid;
      submission_id uuid;
    BEGIN
      -- Get the snapshot ID for the current simple juror
      SELECT id INTO juror_snapshot_id FROM public.voting_session_jurors 
      WHERE juror_id = simple_jurors_ids[i] AND voting_session_id = v_voting_session_id;

      -- Create a submission record
      INSERT INTO public.voting_form_submissions (voting_session_id, voting_session_juror_id) 
      VALUES (v_voting_session_id, juror_snapshot_id) RETURNING id INTO submission_id;

      -- Insert header votes
      INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value)
      VALUES
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'header' AND order_index = 0), (SELECT full_name FROM profiles WHERE id = simple_jurors_ids[i])),
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'header' AND order_index = 1), 'Ingegneria Informatica'),
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'header' AND order_index = 2), (floor(random() * 3 + 1)::text) || '° anno');

      -- Insert participant votes for all 10 participants
      FOR p_idx IN 1..10 LOOP
        INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value, voting_session_participant_id)
        VALUES
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 0), floor(random() * 5 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 1), floor(random() * 5 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx])),
          (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'participant' AND order_index = 2), floor(random() * 5 + 1)::text, (SELECT id FROM voting_session_participants WHERE participation_id = v_participation_ids[p_idx]));
      END LOOP;

      -- Insert footer votes
      INSERT INTO public.voting_form_submission_values (voting_form_submission_id, voting_form_field_id, value)
      VALUES
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'footer' AND order_index = 0), floor(random() * 10 + 1)::text),
        (submission_id, (SELECT id FROM voting_form_fields WHERE voting_form_id = v_simple_jury_form_id AND scope = 'footer' AND order_index = 1), 'Si');

      -- Mark juror as submitted
      UPDATE public.voting_session_jurors SET has_submitted = true WHERE id = juror_snapshot_id;
    END;
  END LOOP;
  
  


  -- ==================================================
  -- PUBLISH A RANKING
  -- ==================================================
  INSERT INTO public.contest_rankings (contest_id, file_path) VALUES (v_contest_id, 'final_ranking.pdf');



  --region CREATE A SECOND CONTEST (also by Mario Rossi)
  v_contest_id := '4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d'; -- Use a new hardcoded ID
  INSERT INTO public.places (address, lat, lon) VALUES ('Colosseo, Roma, Italy', 41.8902, 12.4922) RETURNING id INTO v_place_id;
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths)
  VALUES (v_contest_id, v_organizer_id, 'Roma Street Art Fest', 'Un festival dedicato alla street art nella capitale.', date_trunc('day', now()) + interval '50 days' + interval '18 hours' + interval '30 minutes', now(), now() + interval '30 days', v_place_id, ARRAY[
    'street_art.png'
  ]);

  -- Add a participant to the new contest
  INSERT INTO public.participations (id, contest_id, participant_id, invitation_email) VALUES (participants_ids[5], v_contest_id, participants_ids[5], 'chiara.gatti@example.com');

  -- Add a jury to the new contest
  INSERT INTO public.voting_forms (name, description) VALUES ('Valutazione Street Art', 'Criteri per la street art') RETURNING id INTO v_appointed_jury_form_id;
  INSERT INTO public.juries (contest_id, voting_form_id, name, type) VALUES (v_contest_id, v_appointed_jury_form_id, 'Giuria Esperti Street Art', 'appointed') RETURNING id INTO v_appointed_jury_id;
  INSERT INTO public.jurations (contest_id, jury_id, juror_id, invitation_email) VALUES (v_contest_id, v_appointed_jury_id, technical_jurors_ids[6], 'federica.monti@example.com');

  --region CREATE A THIRD CONTEST (also by Mario Rossi)
  v_contest_id := '5b6c7d8e-9f0a-1b2c-3d4e-5f6a7b8c9d0e'; -- Use another new hardcoded ID
  INSERT INTO public.places (address, lat, lon) VALUES ('MAXXI, Roma, Italy', 41.928, 12.466) RETURNING id INTO v_place_id;
  INSERT INTO public.contests (id, organizer_id, name, description, date_time, works_submission_start, works_submission_end, place_id, images_paths) VALUES (v_contest_id, v_organizer_id, 'Architettura del Futuro', 'Concorso per giovani architetti.', date_trunc('day', now()) + interval '82 days' + interval '15 hours', now() + interval '10 days', now() + interval '40 days', v_place_id, ARRAY[
    'arch.png'
  ]);
  -- This contest is left intentionally empty (no participants or juries yet) to test a different state.

END $$;

-- Re-enable RLS on all tables