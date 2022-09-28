SELECT
  pi.external_identifier                                                    AS participant_id,
  u.full_name                                                               AS participant_name,
  tp.trn                                                                    AS trn,
  pp.type                                                                   AS participant_type,
  pp.mentor_profile_id                                                      AS mentor_profile_id,
  sch.schedule_identifier                                                   AS schedule,
  case epe.status WHEN 'eligible' THEN true ELSE false END                  AS eligible_for_funding,
  case WHEN epe.status != 'eligible' THEN epe.reason ELSE NULL END          AS eligible_for_funding_reason,
  pp.sparsity_uplift                                                        AS sparsity_uplift,
  pp.pupil_premium_uplift                                                   AS pupil_premium_uplift,
  CASE
    WHEN pp.sparsity_uplift AND pp.pupil_premium_uplift THEN true
    ELSE false
  END                                                                       AS sparsity_and_pp,
  lp.name                                                                   AS lead_provider_name,
  lp.id                                                                     AS lead_provider_id,
  dp.name                                                                   AS delivery_partner_name,
  latest_induction_record.training_status                                   AS training_status,
  pps.reason                                                                AS training_status_reason,
  sc.urn                                                                    AS school_urn,
  sc.name                                                                   AS school_name,
  pd.id                                                                     AS declaration_id,
  pd.state                                                                  AS declaration_status,
  pd.declaration_type                                                       AS declaration_type,
  pd.declaration_date                                                       AS declaration_date,
  pd.created_at                                                             AS declaration_created_at,
  s.name                                                                    AS statement_name,
  s.id                                                                      AS statement id
FROM participant_declarations pd
JOIN statement_line_items sli  ON sli.participant_declaration_id = pd.id
JOIN statements s              ON s.id = sli.statement_id
JOIN cpd_lead_providers clp    ON clp.id = pd.cpd_lead_provider_id
JOIN lead_providers lp         ON lp.cpd_lead_provider_id = clp.id
JOIN participant_profiles pp   ON pd.participant_profile_id = pp.id
LEFT OUTER JOIN participant_profile_states pps ON pps.participant_profile_id = pp.id AND pps.cpd_lead_provider_id = clp.id AND pps.state = 'withdrawn'
JOIN participant_identities pi ON pp.participant_identity_id = pi.id
JOIN users u                   ON u.id = pi.external_identifier
JOIN teacher_profiles tp       ON tp.id = pp.teacher_profile_id
JOIN (
     SELECT
        DISTINCT ON (participant_profile_id, lead_provider_id) participant_profile_id,
        lead_provider_id,
        schedule_id,
        training_status,
        partnership_id,
        school_id,
        delivery_partner_id
     FROM induction_records
     JOIN induction_programmes ON induction_programmes.id = induction_records.induction_programme_id
     JOIN partnerships ON partnerships.id = induction_programmes.partnership_id
     ORDER BY participant_profile_id, lead_provider_id, induction_records.created_at DESC
) AS latest_induction_record ON latest_induction_record.participant_profile_id = pd.participant_profile_id AND latest_induction_record.lead_provider_id = lp.id
JOIN schedules sch ON sch.id = latest_induction_record.schedule_id
JOIN schools sc ON sc.id = latest_induction_record.school_id
LEFT OUTER JOIN ecf_participant_eligibilities epe ON epe.participant_profile_id = pp.id
JOIN delivery_partners dp ON dp.id = latest_induction_record.delivery_partner_id
WHERE pp.type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor')
ORDER BY u.full_name ASC
