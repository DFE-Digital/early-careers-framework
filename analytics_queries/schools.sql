\copy (
    SELECT DISTINCT s.urn,
                    sc.induction_programme_choice,
                    (p.id IS NOT NULL)                 as in_partnership,
                    lp.name                            as lead_provider_name,
                    dp.name                            as delivery_partner_name,
                    (icp.id IS NOT NULL)               as tutor_nominated,
                    icp.created_at                     as tutor_nominated_at,
                    (u.current_sign_in_at IS NOT NULL) as tutor_signed_in,
                    u.full_name                        as tutor_name,
                    u.email                            as tutor_email,
                    (pp.id IS NOT NULL)                as sit_mentor,
                    u.id                              as sit_mentor_id

    FROM schools s
            LEFT OUTER JOIN school_cohorts sc on s.id = sc.school_id
            LEFT OUTER JOIN cohorts c on sc.cohort_id = c.id
            LEFT OUTER JOIN partnerships p on s.id = p.school_id
            LEFT OUTER JOIN lead_providers lp on p.lead_provider_id = lp.id
            LEFT OUTER JOIN delivery_partners dp on p.delivery_partner_id = dp.id
            LEFT OUTER JOIN induction_coordinator_profiles_schools icps on s.id = icps.school_id
            LEFT OUTER JOIN induction_coordinator_profiles icp on icps.induction_coordinator_profile_id = icp.id
            LEFT OUTER JOIN users u on icp.user_id = u.id
            LEFT OUTER JOIN teacher_profiles tp on u.id = tp.user_id
            LEFT OUTER JOIN participant_profiles pp on tp.id = pp.teacher_profile_id and pp.status = 'active' and
                                                        pp.type = 'ParticipantProfile::Mentor'
    WHERE (c.start_year > 2020 OR c.id IS NULL)
) to '/tmp/exports/schools.csv' with csv header;
