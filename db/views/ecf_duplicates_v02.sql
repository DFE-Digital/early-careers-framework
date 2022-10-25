SELECT
  participant_identities.user_id AS user_id,
  participant_identities.external_identifier AS external_identifier,
  participant_profiles.id,
  participant_profiles.created_at,
  participant_profiles.updated_at,
  FIRST_VALUE(participant_profiles.id) OVER (
               PARTITION BY participant_profiles.participant_identity_id
               ORDER BY CASE
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status = 'active' THEN 1
               WHEN latest_induction_records.training_status = 'active' AND latest_induction_records.induction_status != 'active' THEN 2
               WHEN latest_induction_records.training_status != 'active' AND latest_induction_records.induction_status = 'active' THEN 3
               ELSE 4 END
  ) AS primary_participant_profile_id,
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
  latest_induction_records.lead_provider_name  AS provider_name,
  latest_induction_records.training_programme,
  schedules.schedule_identifier,
  cohorts.start_year   AS cohort,
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
  ) AS participant_profile_status
FROM participant_profiles
LEFT OUTER JOIN (
     SELECT
       induction_records.*,
       partnerships.lead_provider_id,
       schools.id AS school_id,
       schools.name AS school_name,
       lead_providers.name AS lead_provider_name,
       induction_programmes.training_programme AS training_programme,
       ROW_NUMBER() OVER (PARTITION BY participant_profile_id ORDER BY induction_records.created_at DESC) AS induction_record_sort_order
     FROM induction_records
     JOIN induction_programmes ON induction_programmes.id = induction_records.induction_programme_id
     LEFT OUTER JOIN partnerships         ON partnerships.id         = induction_programmes.partnership_id
     LEFT OUTER JOIN lead_providers       ON lead_providers.id       = partnerships.lead_provider_id
     LEFT OUTER JOIN schools              ON schools.id              = partnerships.school_id
) AS latest_induction_records ON latest_induction_records.participant_profile_id = participant_profiles.id AND induction_record_sort_order = 1
JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id
JOIN (
      SELECT
        user_id,
        COUNT(*) as count
      FROM participant_profiles
      JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id
      JOIN users ON users.id = participant_identities.user_id
      WHERE type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor')
      GROUP BY type, user_id
) AS duplicates ON duplicates.user_id = participant_identities.user_id
JOIN teacher_profiles ON teacher_profiles.id = participant_profiles.teacher_profile_id
JOIN schedules ON latest_induction_records.schedule_id = schedules.id
JOIN cohorts ON schedules.cohort_id = cohorts.id
LEFT OUTER JOIN (
     SELECT participant_profile_id, COUNT(*) AS count FROM participant_declarations GROUP BY participant_profile_id
) AS declarations ON participant_profiles.id = declarations.participant_profile_id
WHERE participant_identities.user_id IN (
      SELECT user_id
      FROM participant_profiles
      JOIN participant_identities ON participant_identities.id = participant_profiles.participant_identity_id
      JOIN users ON users.id = participant_identities.user_id
      WHERE type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor')
      GROUP BY type, user_id
      HAVING COUNT(*) > 1)
ORDER BY participant_identities.external_identifier ASC, participant_profile_status ASC, participant_profiles.created_at DESC;
