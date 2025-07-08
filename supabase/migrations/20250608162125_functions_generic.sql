-- GET CONTEST DETAILS
CREATE OR REPLACE FUNCTION get_contest_details (
  p_contest_id uuid
)
RETURNS TABLE (
  contest jsonb,
  organizer jsonb,
  place jsonb,
  participations jsonb,
  participants jsonb,
  works jsonb,
  jurations jsonb,
  jurors jsonb,
  invitations jsonb,
  voting_form jsonb,
  voting_form_fields jsonb,
  voting_sessions jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      to_jsonb(cont) AS contest,
      to_jsonb(org) AS organizer,
      to_jsonb(pla) AS place,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part) ORDER BY pro.full_name ASC)
         FROM participations part
         JOIN profiles pro ON pro.id = part.participant_id
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS participations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(par))
         FROM profiles par
         JOIN participations part ON par.id = part.participant_id
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS participants,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(wor))
         FROM works wor
         JOIN participations part
          ON wor.participation_id = part.id
            AND part.has_submitted = true
            AND part.participant_status = 'joined'
         WHERE part.contest_id = cont.id
        ), '[]'::jsonb) AS works,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jura) ORDER BY pro.full_name ASC)
         FROM jurations jura
         JOIN profiles pro ON pro.id = jura.juror_id
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurations,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(juro))
         FROM profiles juro
         JOIN jurations jura ON juro.id = jura.juror_id
         WHERE jura.contest_id = cont.id
        ), '[]'::jsonb) AS jurors,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(inv) ORDER BY inv.created_at DESC)
         FROM invitations inv
         WHERE inv.contest_id = cont.id
        ), '[]'::jsonb) AS invitations,
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = cont.voting_form_id
        ), 'null'::jsonb) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vf_field) ORDER BY vf_field.order_index ASC)
         FROM voting_form_fields vf_field
         WHERE vf_field.voting_form_id = cont.voting_form_id
        ), '[]'::jsonb) AS voting_form_fields,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vs) ORDER BY vs.created_at DESC)
         FROM voting_sessions vs
         WHERE vs.contest_id = cont.id
        ), '[]'::jsonb) AS voting_sessions
    FROM contests cont
    JOIN profiles org ON cont.organizer_id = org.id
    JOIN places pla ON cont.place_id = pla.id
    WHERE cont.id = p_contest_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- GET VOTING SESSION PROCEDURE BUNDLE
CREATE OR REPLACE FUNCTION get_voting_session_procedure_bundle (
  p_voting_session_id uuid
)
RETURNS TABLE (
  participations jsonb,
  participants jsonb,
  works jsonb,
  jurations jsonb,
  jurors jsonb,
  voting_form jsonb,
  voting_form_fields jsonb,
  voting_session jsonb,
  geo_res_place jsonb,
  voting_session_participations jsonb,
  voting_session_jurations jsonb,
  voting_session_exclusions jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      -- all participations for the contest
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part) ORDER BY pro.full_name ASC)
         FROM participations part
         JOIN profiles pro ON pro.id = part.participant_id
         WHERE part.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS participations,
      -- all participant profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(pr))
         FROM profiles pr
         JOIN participations p ON pr.id = p.participant_id
         WHERE p.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS participants,
      -- submitted works of joined participants
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(w))
         FROM works w
         JOIN participations p ON w.participation_id = p.id
         WHERE p.contest_id = c.id
           AND p.has_submitted = TRUE
           AND p.participant_status = 'joined'
        ),
        '[]'::jsonb
      ) AS works,
      -- all juration records
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur) ORDER BY pro.full_name ASC)
         FROM jurations jur
         JOIN profiles pro ON pro.id = jur.juror_id
         WHERE jur.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS jurations,
      -- juror profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jp))
         FROM profiles jp
         JOIN jurations j ON jp.id = j.juror_id
         WHERE j.contest_id = c.id
        ),
        '[]'::jsonb
      ) AS jurors,
      -- associated voting form
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = c.voting_form_id
        ),
        'null'::jsonb
      ) AS voting_form,
      -- fields of that voting form
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(ff) ORDER BY ff.order_index ASC)
         FROM voting_form_fields ff
         WHERE ff.voting_form_id = c.voting_form_id
        ),
        '[]'::jsonb
      ) AS voting_form_fields,
      -- single voting session requested
      to_jsonb(ses) AS voting_session,
      -- optional geographic restriction place (can be null)
      to_jsonb(geopla) AS geo_res_place,
      -- participations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index ASC)
         FROM voting_session_participations vsp
         WHERE vsp.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_participations,
      -- jurations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsj))
         FROM voting_session_jurations vsj
         WHERE vsj.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_jurations,
      -- exclusions in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vse))
         FROM voting_session_exclusions vse
         WHERE vse.voting_session_id = ses.id
        ),
        '[]'::jsonb
      ) AS voting_session_exclusions

    FROM voting_sessions ses
    JOIN contests c ON ses.contest_id = c.id
    LEFT JOIN places geopla ON ses.geo_res_place_id = geopla.id
    WHERE ses.id = p_voting_session_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING SESSION RESULT BUNDLE
CREATE OR REPLACE FUNCTION get_voting_session_result_bundle (
  p_voting_session_id uuid
)
RETURNS TABLE (
  participations jsonb,
  participants jsonb,
  works jsonb,
  jurations jsonb,
  jurors jsonb,
  voting_form jsonb,
  voting_form_fields jsonb,
  voting_session jsonb,
  geo_res_place jsonb,
  voting_session_participations jsonb,
  voting_session_jurations jsonb,
  voting_session_exclusions jsonb,
  simple_jurors jsonb,
  voting_session_simple_jurors jsonb,
  raw_jurors_votings jsonb,
  raw_jurors_votes jsonb,
  raw_simple_jurors_votings jsonb,
  raw_simple_jurors_votes jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      -- 1) all participations for the contest
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(part) ORDER BY pro.full_name ASC)
         FROM participations part
         JOIN profiles pro ON pro.id = part.participant_id
         WHERE part.contest_id = c.id),
        '[]'::jsonb
      ) AS participations,

      -- 2) all participant profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(pr))
         FROM profiles pr
         JOIN participations p ON pr.id = p.participant_id
         WHERE p.contest_id = c.id),
        '[]'::jsonb
      ) AS participants,

      -- 3) submitted works of joined participants
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(w))
         FROM works w
         JOIN participations p ON w.participation_id = p.id
         WHERE p.contest_id = c.id
           AND p.has_submitted = TRUE
           AND p.participant_status = 'joined'),
        '[]'::jsonb
      ) AS works,

      -- 4) all juration records
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jur) ORDER BY pro.full_name ASC)
         FROM jurations jur
         JOIN profiles pro ON pro.id = jur.juror_id
         WHERE jur.contest_id = c.id),
        '[]'::jsonb
      ) AS jurations,

      -- 5) juror profiles
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jp))
         FROM profiles jp
         JOIN jurations j ON jp.id = j.juror_id
         WHERE j.contest_id = c.id),
        '[]'::jsonb
      ) AS jurors,

      -- 6) associated voting form
      COALESCE(
        (SELECT to_jsonb(vf)
         FROM voting_forms vf
         WHERE vf.id = c.voting_form_id),
        'null'::jsonb
      ) AS voting_form,

      -- 7) fields of that voting form
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(ff) ORDER BY ff.order_index ASC)
         FROM voting_form_fields ff
         WHERE ff.voting_form_id = c.voting_form_id),
        '[]'::jsonb
      ) AS voting_form_fields,

      -- 8) single voting session requested
      to_jsonb(ses) AS voting_session,

      -- 9) optional geographic restriction place (can be null)
      to_jsonb(geopla) AS geo_res_place,

      -- 10) participations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsp) ORDER BY vsp.order_index ASC)
         FROM voting_session_participations vsp
         WHERE vsp.voting_session_id = ses.id),
        '[]'::jsonb
      ) AS voting_session_participations,

      -- 11) jurations in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vsj))
         FROM voting_session_jurations vsj
         WHERE vsj.voting_session_id = ses.id),
        '[]'::jsonb
      ) AS voting_session_jurations,

      -- 12) exclusions in this voting session
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vse))
         FROM voting_session_exclusions vse
         WHERE vse.voting_session_id = ses.id),
        '[]'::jsonb
      ) AS voting_session_exclusions,

      -- 13) all simple jurors (the “who can vote by token”)
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(simjur) ORDER BY simjur.full_name ASC)
         FROM simple_jurors simjur
         JOIN voting_session_simple_jurors vsjs ON simjur.id = vsjs.simple_juror_id
         WHERE vsjs.voting_session_id = ses.id),
        '[]'::jsonb
      ) AS simple_jurors,

      -- 14) linking table entries for those simple jurors
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(vssj) ORDER BY simjur.full_name ASC)
         FROM voting_session_simple_jurors vssj
         JOIN simple_jurors simjur ON vssj.simple_juror_id = simjur.id
         WHERE vssj.voting_session_id = ses.id),
        '[]'::jsonb
      ) AS voting_session_simple_jurors,

      -- 15) raw juror votings
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jv))
         FROM juror_votings jv
         JOIN voting_session_jurations vsj ON jv.voting_session_juration_id = vsj.id
         WHERE vsj.voting_session_id = p_voting_session_id),
        '[]'::jsonb
      ) AS raw_juror_votings,

      -- 16) raw juror votes
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(jv2))
         FROM juror_votes jv2
         JOIN juror_votings jv ON jv2.juror_voting_id = jv.id
         JOIN voting_session_jurations vsj2 ON jv.voting_session_juration_id = vsj2.id
         WHERE vsj2.voting_session_id = p_voting_session_id),
        '[]'::jsonb
      ) AS raw_juror_votes,

      -- 17) raw simple juror votings
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(sjv))
         FROM simple_juror_votings sjv
         JOIN voting_session_simple_jurors vssj ON sjv.voting_session_simple_juror_id = vssj.id
         WHERE vssj.voting_session_id = p_voting_session_id),
        '[]'::jsonb
      ) AS raw_simple_jurors_votings,

      -- 18) raw simple juror votes
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(sjv2))
         FROM simple_juror_votes sjv2
         JOIN simple_juror_votings sjv ON sjv2.simple_juror_voting_id = sjv.id
         JOIN voting_session_simple_jurors vssj2 ON sjv.voting_session_simple_juror_id = vssj2.id
         WHERE vssj2.voting_session_id = p_voting_session_id),
        '[]'::jsonb
      ) AS raw_simple_jurors_votes

    FROM voting_sessions ses
    JOIN contests c ON ses.contest_id = c.id
    LEFT JOIN places geopla ON ses.geo_res_place_id = geopla.id
    WHERE ses.id = p_voting_session_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- GET VOTING FORM BUNDLE
CREATE OR REPLACE FUNCTION get_voting_form_bundle (
  p_voting_form_id uuid
)
RETURNS TABLE (
  voting_form jsonb,
  voting_form_fields jsonb
) AS $$
BEGIN

  RETURN QUERY
    SELECT
      to_jsonb(form) AS voting_form,
      COALESCE(
        (SELECT jsonb_agg(to_jsonb(field) ORDER BY field.order_index)
         FROM voting_form_fields field
         WHERE field.voting_form_id = p_voting_form_id
        ), '[]'::jsonb) AS voting_form_fields
    FROM voting_forms form
    WHERE form.id = p_voting_form_id
    LIMIT 1;

EXCEPTION
  WHEN SQLSTATE 'P0001' THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE EXCEPTION 'An unexcepted error occurred';
END;
$$ LANGUAGE plpgsql SECURITY definer;