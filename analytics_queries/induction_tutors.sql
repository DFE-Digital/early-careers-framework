\copy (
  SELECT s.urn,
          (icp.id IS NOT NULL)               AS tutor_nominated,
          icp.created_at                     AS tutor_nominated_at,
          (u.current_sign_in_at IS NOT NULL) AS tutor_signed_in,
          u.full_name                        AS tutor_name,
          u.email                            AS tutor_email,
          (pp.id IS NOT NULL)                AS sit_mentor,
          pi.external_identifier             AS sit_mentor_id

    FROM schools s

    LEFT OUTER JOIN induction_coordinator_profiles_schools icps on s.id = icps.school_id
    LEFT OUTER JOIN induction_coordinator_profiles icp on icps.induction_coordinator_profile_id = icp.id
    LEFT OUTER JOIN users u on icp.user_id = u.id
    LEFT OUTER JOIN teacher_profiles tp on u.id = tp.user_id
    LEFT OUTER JOIN participant_profiles pp
      ON tp.id = pp.teacher_profile_id
      AND pp.status = 'active'
      AND pp.type = 'ParticipantProfile::Mentor'
    LEFT OUTER JOIN participant_identities pi on pp.participant_identity_id = pi.id
) to '/tmp/exports/induction_tutors.csv' with csv header;
