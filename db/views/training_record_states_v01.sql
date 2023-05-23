WITH
    mentee_counts AS (
        SELECT
            "induction_records"."mentor_profile_id",
            count(*) as total
        FROM "induction_records"
        GROUP BY
            "induction_records"."mentor_profile_id",
            "induction_records"."participant_profile_id"
    ),
    individual_training_record_states AS (
        SELECT
            "participant_profiles"."id"                 as "participant_profile_id",
            "participant_profiles"."type"               as "participant_profile_type",
            "induction_records"."id"                    as "induction_record_id",
            CASE
                WHEN "partnerships"."school_id" IS NOT NULL THEN "partnerships"."school_id"
                ELSE "school_cohorts"."school_id"
                END                                     as "school_id",
            "partnerships"."lead_provider_id"           as "lead_provider_id",
            "partnerships"."delivery_partner_id"        as "delivery_partner_id",
            "induction_records"."appropriate_body_id"   as "appropriate_body_id",
            "induction_programmes"."training_programme" as "training_programme",

            GREATEST(
                    "induction_records"."start_date",
                    "participant_profiles"."updated_at",
                    "ecf_participant_eligibilities"."updated_at",
                    "ecf_participant_validation_data"."updated_at",
                    "teacher_profiles"."updated_at",
                    "emails"."updated_at"
                ) AS changed_at,

            CASE
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'different_trn'
                    THEN 'different_trn'
                WHEN "teacher_profiles"."trn" IS NULL AND "ecf_participant_validation_data" IS NULL
                    THEN
                    CASE
                        WHEN "emails"."status" = 'delivered'
                            THEN 'request_for_details_delivered'
                        WHEN "emails"."status" IN ('permanent-failure', 'technical-failure', 'temporary-failure')
                            THEN 'request_for_details_failed'
                        WHEN "emails"."status" = 'submitted'
                            THEN 'request_for_details_submitted'
                        ELSE
                            'validation_not_started'
                        END
                WHEN "ecf_participant_validation_data"."api_failure" = TRUE
                    THEN 'internal_error'
                WHEN "teacher_profiles"."trn" IS NULL
                    THEN 'tra_record_not_found'
                ELSE
                    'valid'
                END as "validation_state",

            CASE
                WHEN ("participant_profiles"."type" = 'ParticipantProfile::ECT' AND "ecf_participant_eligibilities" IS NULL) OR ("teacher_profiles"."trn" IS NOT NULL AND "ecf_participant_eligibilities" IS NULL)
                    THEN 'checks_not_complete'
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'active_flags'
                    THEN 'active_flags'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'active_flags'
                    THEN 'not_allowed'
                WHEN "participant_profiles"."type" = 'ParticipantProfile::Mentor'
                    THEN
                    CASE
                        WHEN "mentee_counts"."total" > 0
                            THEN 'eligible_for_mentor_training'
                        ELSE
                            'not_yet_mentoring'
                        END
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'duplicate_profile'
                    THEN 'duplicate_profile'
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'no_qts'
                    THEN 'not_qualified'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'exempt_from_induction'
                    THEN 'exempt_from_induction'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'previous_induction'
                    THEN 'previous_induction'
                WHEN ("participant_profiles"."type" = 'ParticipantProfile::Mentor' AND "ecf_participant_validation_data"."trn" IS NOT NULL AND "teacher_profiles"."trn" IS NULL) OR ("participant_profiles"."type" = 'ParticipantProfile::ECT' AND "teacher_profiles"."trn" IS NULL)
                    THEN 'tra_record_not_found'
                ELSE
                    'eligible_for_induction_training'
                END as "training_eligibility_state",

            CASE
                WHEN ("participant_profiles"."type" = 'ParticipantProfile::ECT' AND "ecf_participant_eligibilities" IS NULL) OR ("teacher_profiles"."trn" IS NOT NULL AND "ecf_participant_eligibilities" IS NULL)
                    THEN 'checks_not_complete'
                WHEN "participant_profiles"."type" = 'ParticipantProfile::ECT' AND "ecf_participant_eligibilities"."status" = 'eligible'
                    THEN 'eligible_for_fip_funding'
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'active_flags'
                    THEN 'active_flags'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'active_flags'
                    THEN 'not_allowed'
                WHEN "participant_profiles"."type" = 'ParticipantProfile::Mentor' AND "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'previous_participation'
                    THEN
                    CASE
                        WHEN "participant_profiles"."profile_duplicity" = 'secondary'
                            THEN 'ineligible_ero_secondary'
                        WHEN "participant_profiles"."profile_duplicity" = 'primary'
                            THEN 'ineligible_ero_primary'
                        WHEN "ecf_participant_eligibilities"."reason" = 'duplicate_profile'
                            THEN 'ineligible_ero_secondary'
                        ELSE
                            'ineligible_ero'
                        END
                WHEN "participant_profiles"."type" = 'ParticipantProfile::Mentor'
                    THEN
                    CASE
                        WHEN "participant_profiles"."profile_duplicity" = 'secondary'
                            THEN 'ineligible_secondary'
                        WHEN "participant_profiles"."profile_duplicity" = 'primary'
                            THEN 'eligible_for_mentor_funding_primary'
                        WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'duplicate_profile'
                            THEN 'ineligible_secondary'
                        ELSE
                            'eligible_for_mentor_funding'
                        END
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'no_induction'
                    THEN 'no_induction_start'
                WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'no_qts'
                    THEN 'not_qualified'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'duplicate_profile'
                    THEN 'duplicate_profile'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'exempt_from_induction'
                    THEN 'exempt_from_induction'
                WHEN "ecf_participant_eligibilities"."status" = 'ineligible' AND "ecf_participant_eligibilities"."reason" = 'previous_induction'
                    THEN 'previous_induction'
                WHEN ("participant_profiles"."type" = 'ParticipantProfile::Mentor' AND "ecf_participant_validation_data"."trn" IS NOT NULL AND "teacher_profiles"."trn" IS NULL) OR ("participant_profiles"."type" = 'ParticipantProfile::ECT' AND "teacher_profiles"."trn" IS NULL)
                    THEN 'tra_record_not_found'
                ELSE
                    'eligible_for_fip_funding'
                END as "fip_funding_eligibility_state",

            CASE
                WHEN "participant_profiles"."type" = 'ParticipantProfile::Mentor'
                    THEN
                    CASE
                        WHEN "mentee_counts"."total" > 0
                            THEN
                            CASE
                                WHEN "induction_programmes"."training_programme" = 'full_induction_programme'
                                    THEN
                                    CASE
                                        WHEN "ecf_participant_eligibilities"."reason" = 'previous_participation'
                                            THEN 'active_fip_mentoring_ero'
                                        ELSE
                                            'active_fip_mentoring'
                                        END
                                WHEN "induction_programmes"."training_programme" = 'core_induction_programme'
                                    THEN
                                    CASE
                                        WHEN "ecf_participant_eligibilities"."reason" = 'previous_participation'
                                            THEN 'active_cip_mentoring_ero'
                                        ELSE
                                            'active_cip_mentoring'
                                        END
                                WHEN "induction_programmes"."training_programme" = 'design_our_own'
                                    THEN
                                    CASE
                                        WHEN "ecf_participant_eligibilities"."reason" = 'previous_participation'
                                            THEN 'active_diy_mentoring_ero'
                                        ELSE
                                            'active_diy_mentoring'
                                        END
                                ELSE
                                    'active_mentoring'
                                END
                        ELSE
                            CASE
                                WHEN "ecf_participant_eligibilities"."reason" = 'previous_participation'
                                    THEN 'not_yet_mentoring_ero'
                                ELSE
                                    'not_yet_mentoring'
                                END
                        END
                ELSE
                    'not_a_mentor'
                END as "mentoring_state",

            CASE
                WHEN "induction_records"."induction_status" = 'changed'
                    THEN 'no_longer_involved'
                WHEN "induction_records"."induction_status" = 'leaving' AND "induction_records"."end_date" >= CURRENT_DATE
                    THEN 'leaving'
                WHEN "induction_records"."induction_status" = 'leaving' AND "induction_records"."end_date" < CURRENT_DATE
                    THEN 'left'
                WHEN "induction_records"."induction_status" = 'active' AND "induction_records"."start_date" > CURRENT_DATE
                    THEN 'joining'

                WHEN "induction_records"."induction_status" = 'withdrawn' OR ("induction_records" IS NULL AND "participant_profiles"."status" = 'withdrawn')
                    THEN 'withdrawn_programme'
                WHEN "induction_records"."training_status" = 'withdrawn' OR ("induction_records" IS NULL AND "participant_profiles"."training_status" = 'withdrawn')
                    THEN 'withdrawn_training'
                WHEN "induction_records"."training_status" = 'deferred' OR ("induction_records" IS NULL AND "participant_profiles"."training_status" = 'deferred')
                    THEN 'deferred_training'
                WHEN "induction_records"."induction_status" = 'completed' OR ("induction_records" IS NULL AND "participant_profiles"."status" = 'completed')
                    THEN 'completed_training'
                WHEN "induction_programmes"."training_programme" = 'full_induction_programme'
                    THEN
                    CASE
                        WHEN "partnerships"."lead_provider_id" IS NULL
                            THEN 'registered_for_fip_no_partner'
                        WHEN "participant_profiles"."induction_start_date" < CURRENT_DATE
                            THEN  'active_fip_training'
                        ELSE
                            'registered_for_fip_training'
                        END
                WHEN "induction_programmes"."training_programme" = 'core_induction_programme'
                    THEN
                    CASE
                        WHEN "participant_profiles"."induction_start_date" < CURRENT_DATE
                            THEN  'active_cip_training'
                        ELSE
                            'registered_for_cip_training'
                        END
                WHEN "induction_programmes"."training_programme" = 'design_our_own'
                    THEN
                    CASE
                        WHEN "participant_profiles"."induction_start_date" < CURRENT_DATE
                            THEN  'active_diy_training'
                        ELSE
                            'registered_for_diy_training'
                        END
                ELSE
                    'not_registered_for_training'
                END as "training_state"

        FROM "participant_profiles"
                 LEFT OUTER JOIN "induction_records"
                                 ON "induction_records"."participant_profile_id" = "participant_profiles"."id"
                 LEFT OUTER JOIN "induction_programmes"
                                 ON "induction_programmes"."id" = "induction_records"."induction_programme_id"
                 LEFT OUTER JOIN "partnerships"
                                 ON "partnerships"."id" = "induction_programmes"."partnership_id"
                 LEFT OUTER JOIN "school_cohorts"
                                 ON "school_cohorts"."id" = "induction_programmes"."school_cohort_id"
                 LEFT OUTER JOIN "ecf_participant_validation_data"
                                 ON "ecf_participant_validation_data"."participant_profile_id" = "participant_profiles"."id"
                 LEFT OUTER JOIN "ecf_participant_eligibilities"
                                 ON "ecf_participant_eligibilities"."participant_profile_id" = "participant_profiles"."id"
                 LEFT OUTER JOIN "teacher_profiles"
                                 ON "teacher_profiles"."id" = "participant_profiles"."teacher_profile_id"
                 LEFT OUTER JOIN "email_associations"
                                 ON "email_associations"."object_id" = "participant_profiles"."id" AND "email_associations"."object_type" = 'ParticipantProfile'
                 LEFT OUTER JOIN "emails"
                                 ON "emails"."id" = "email_associations"."email_id" AND 'request_for_details' = ANY ("emails"."tags")
                 LEFT OUTER JOIN "mentee_counts"
                                 ON "mentee_counts"."mentor_profile_id" = "participant_profiles"."id"
    )

SELECT
    "individual_training_record_states"."participant_profile_id",
    "individual_training_record_states"."induction_record_id",
    "individual_training_record_states"."school_id",
    "individual_training_record_states"."lead_provider_id",
    "individual_training_record_states"."delivery_partner_id",
    "individual_training_record_states"."appropriate_body_id",
    MIN("individual_training_record_states"."changed_at") as "changed_at",
    "individual_training_record_states"."validation_state",
    "individual_training_record_states"."training_eligibility_state",
    "individual_training_record_states"."fip_funding_eligibility_state",
    "individual_training_record_states"."mentoring_state",
    "individual_training_record_states"."training_state",

    CASE
        WHEN "individual_training_record_states"."training_state" IN (
                                                                      'withdrawn_programme',
                                                                      'joining',
                                                                      'leaving',
                                                                      'left'
                                                                     )
            THEN "individual_training_record_states"."training_state"
        WHEN "individual_training_record_states"."training_state" IN (
                                                                      'withdrawn_training',
                                                                      'deferred_training',
                                                                      'completed_training'
                                                                     )
            THEN
            CASE
                WHEN "individual_training_record_states"."mentoring_state" = 'not_a_mentor'
                    THEN "individual_training_record_states"."training_state"
                ELSE
                    "individual_training_record_states"."mentoring_state"
                END
        WHEN "individual_training_record_states"."validation_state" <> 'valid'
            THEN "individual_training_record_states"."validation_state"
        WHEN NOT "individual_training_record_states"."training_eligibility_state" IN (
                                                                                      'eligible_for_mentor_training',
                                                                                      'eligible_for_induction_training'
                                                                                     )
            THEN "individual_training_record_states"."training_eligibility_state"
        WHEN "individual_training_record_states"."training_programme" = 'full_induction_programme'
                 AND NOT "individual_training_record_states"."fip_funding_eligibility_state" IN (
                                                                                                 'eligible_for_mentor_funding',
                                                                                                 'eligible_for_mentor_funding_primary',
                                                                                                 'eligible_for_fip_funding',
                                                                                                 'ineligible_secondary',
                                                                                                 'ineligible_ero',
                                                                                                 'ineligible_ero_secondary'
                                                                                                )
            THEN "individual_training_record_states"."fip_funding_eligibility_state"
        WHEN "individual_training_record_states"."participant_profile_type" = 'ParticipantProfile::Mentor'
            THEN "individual_training_record_states"."mentoring_state"
        ELSE
            "individual_training_record_states"."training_state"
        END as "record_state"

FROM individual_training_record_states

GROUP BY
    "individual_training_record_states"."participant_profile_id",
    "individual_training_record_states"."induction_record_id",
    "individual_training_record_states"."school_id",
    "individual_training_record_states"."lead_provider_id",
    "individual_training_record_states"."delivery_partner_id",
    "individual_training_record_states"."appropriate_body_id",
    "individual_training_record_states"."validation_state",
    "individual_training_record_states"."training_eligibility_state",
    "individual_training_record_states"."fip_funding_eligibility_state",
    "individual_training_record_states"."mentoring_state",
    "individual_training_record_states"."training_state",
    "record_state"
;