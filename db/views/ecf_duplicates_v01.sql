SELECT
  participant_identities.user_id AS user_id,
  participant_identities.external_identifier AS external_identifier,
  participant_profiles.id,
  CASE participant_profiles.type WHEN 'ParticipantProfile::Mentor' THEN 'mentor' ELSE 'ect' END AS profile_type,
  duplicates.count            AS duplicate_profile_count,
  latest_induction_records.id AS latest_induction_record_id,
  latest_induction_records.induction_status,
  latest_induction_records.training_status,
  latest_induction_records.start_date,
  latest_induction_records.end_date,
  latest_induction_records.school_transfer,
  latest_induction_records.school_id,
  latest_induction_records.school_name,
  schedules.schedule_identifier,
  cohorts.start_year   AS cohort,
  lead_providers.name  AS provider_name,
  teacher_profiles.trn AS teacher_profile_trn,
  teacher_profiles.id  AS teacher_profile_id,
  COALESCE(declarations.count, 0) AS declaration_count,
  ROW_NUMBER() OVER (
               PARTITION BY participant_profiles.participant_identity_id
               ORDER BY CASE
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status = 'active' THEN 1
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status != 'active' THEN 2
               WHEN latest_induction_records.training_status != 'active' AND latest_induction_records.induction_status = 'active' THEN 3
               ELSE 4 END
  ) AS participant_profile_status,
  FIRST_VALUE(participant_profiles.id) OVER (
               PARTITION BY participant_profiles.participant_identity_id
               ORDER BY CASE
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status = 'active' THEN 1
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status != 'active' THEN 2
               WHEN latest_induction_records.training_status != 'active' AND latest_induction_records.induction_status = 'active' THEN 3
               ELSE 4 END
  ) AS primary_participant_profile_id
FROM participant_profiles
JOIN (
     SELECT
       induction_records.*,
       partnerships.lead_provider_id,
       schools.id AS school_id,
       schools.name AS school_name,
       lead_providers.name AS lead_provider_name,
       ROW_NUMBER() OVER (PARTITION BY participant_profile_id, partnerships.lead_provider_id ORDER BY induction_records.created_at DESC) AS induction_record_sort_order
     FROM induction_records
     JOIN induction_programmes ON induction_programmes.id = induction_records.induction_programme_id
     JOIN partnerships         ON partnerships.id         = induction_programmes.partnership_id
     JOIN lead_providers       ON lead_providers.id       = partnerships.lead_provider_id
     JOIN schools              ON schools.id              = partnerships.school_id
) AS latest_induction_records ON latest_induction_records.participant_profile_id = participant_profiles.id AND induction_record_sort_order = 1
JOIN lead_providers ON lead_providers.id = latest_induction_records.lead_provider_id
JOIN (
     SELECT COUNT(*) AS count, participant_identity_id
     FROM participant_profiles WHERE type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor') GROUP BY participant_identity_id
) AS duplicates ON duplicates.participant_identity_id = participant_profiles.participant_identity_id
JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id
JOIN teacher_profiles ON teacher_profiles.id = participant_profiles.teacher_profile_id
JOIN schedules ON latest_induction_records.schedule_id = schedules.id
JOIN cohorts ON schedules.cohort_id = cohorts.id
LEFT OUTER JOIN (
     SELECT participant_profile_id, cpd_lead_provider_id, COUNT(*) AS count FROM participant_declarations GROUP BY participant_profile_id, cpd_lead_provider_id
) AS declarations ON participant_profiles.id = declarations.participant_profile_id AND lead_providers.cpd_lead_provider_id = declarations.cpd_lead_provider_id
WHERE participant_profiles.participant_identity_id IN (
      SELECT participant_identity_id
      FROM participant_profiles
      WHERE type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor')
      GROUP BY type, participant_identity_id
      HAVING COUNT(*) > 1)
ORDER BY participant_identities.external_identifier ASC, participant_profile_status ASC, participant_profiles.created_at DESC;
