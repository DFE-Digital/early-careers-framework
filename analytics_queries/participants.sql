\copy (
    SELECT u.id                                                   as participant_id,
          pi.external_identifier                                  as external_id,
          pp.created_at                                           as added_at,
          sch.urn                                                 as school_urn,
          u.full_name                                             as name,
          u.email                                                 as email,
          SPLIT_PART(pp.type, '::', 2)                            as type,
          (SELECT u2.id
            FROM participant_profiles pp2
                    JOIN teacher_profiles tp2 on pp2.teacher_profile_id = tp2.id
                    JOIN users u2 on tp2.user_id = u2.id
            WHERE pp2.id = pp.mentor_profile_id)                  as mentor_id,
          c.start_year                                            as cohort,
          pp.status                                               as status,
          latest_induction_record.training_status                 as training_status,
          pps.reason                                              as training_status_reason,
          s.name                                                  as schedule,
          s.schedule_identifier                                   as schedule_identifier,
          tp.trn                                                  as trn,
          epvd.created_at                                         as trn_provided_at,
          (epe.status IN ('eligible', 'matched'))                 as trn_validated,
          epe.reason                                              as trn_validated_reason,
          (epe.manually_validated OR epe.status = 'manual_check') as manual_validation_required,
          (CASE
                WHEN epe.status = 'eligible' THEN true
                WHEN epe.status = 'ineligible' THEN false
              END)                                                as eligible_for_funding
    FROM participant_profiles pp
            JOIN school_cohorts sc on pp.school_cohort_id = sc.id
            JOIN cohorts c on sc.cohort_id = c.id
            JOIN schools sch on sc.school_id = sch.id
            JOIN schedules s on pp.schedule_id = s.id
            JOIN teacher_profiles tp on pp.teacher_profile_id = tp.id
            JOIN users u on tp.user_id = u.id
            JOIN participant_identities pi on pp.participant_identity_id = pi.id
            LEFT OUTER JOIN ecf_participant_validation_data epvd on pp.id = epvd.participant_profile_id
            LEFT OUTER JOIN ecf_participant_eligibilities epe on pp.id = epe.participant_profile_id
            JOIN (
                 SELECT
                    DISTINCT ON (participant_profile_id) participant_profile_id,
                    training_status
                 FROM induction_records
                 JOIN induction_programmes ON induction_programmes.id = induction_records.induction_programme_id
                 JOIN partnerships ON partnerships.id = induction_programmes.partnership_id
                 ORDER BY participant_profile_id, induction_records.created_at DESC
            ) AS latest_induction_record ON latest_induction_record.participant_profile_id = pp.id
            LEFT OUTER JOIN participant_profile_states pps on pp.id = pps.participant_profile_id AND pps.id = (
              SELECT id from participant_profile_states _pps WHERE _pps.participant_profile_id = pp.id AND _pps.state = latest_induction_record.training_status ORDER BY created_at desc LIMIT 1
            )
    WHERE pp.type IN ('ParticipantProfile::ECT', 'ParticipantProfile::Mentor')
      AND c.start_year > 2020
) to '/tmp/exports/participants.csv' with csv header;
