# frozen_string_literal: true

# noinspection RubyTooManyMethodsInspection, RubyTooManyInstanceVariablesInspection, RubyInstanceMethodNamingConvention
#
# DetermineTrainingRecordState returns a DetermineTrainingRecordState::Record for a given participant that
# contains the provided IDs along with the following states which can have the nested values:
#
# validation_state:
#   different_trn
#   internal_error
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   valid
#   validation_not_started
#
# training_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_induction_training
#   eligible_for_mentor_training
#   exempt_from_induction
#   not_allowed
#   not_qualified
#   not_yet_mentorin
#   previous_induction
#   tra_record_not_found
#
# fip_funding_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_fip_funding
#   eligible_for_mentor_funding
#   eligible_for_mentor_funding_primary
#   exempt_from_induction
#   ineligible_ero
#   ineligible_ero_primary
#   ineligible_ero_secondary
#   ineligible_secondary
#   no_induction_start
#   not_allowed
#   not_qualified
#   previous_induction
#   tra_record_not_foun
#
# mentoring_state:
#   active_mentoring
#   active_mentoring_ero
#   not_a_mentor
#   not_yet_mentoring
#   not_yet_mentoring_ero
#
# training_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   completed_training
#   deferred_training
#   joining
#   leaving
#   left
#   no_longer_involved
#   not_registered_for_training
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   withdrawn_programme
#   withdrawn_training
#
# record_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   active_flags
#   active_mentoring
#   active_mentoring_ero
#   checks_not_complete
#   completed_training
#   deferred_training
#   different_trn
#   duplicate_profile
#   exempt_from_induction
#   internal_error
#   joining
#   leaving
#   left
#   no_induction_start
#   no_longer_involved
#   not_allowed
#   not_qualified
#   not_registered_for_training
#   not_yet_mentoring
#   not_yet_mentoring_ero
#   previous_induction
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   validation_not_started
#   withdrawn_programme
#   withdrawn_training
class DetermineTrainingRecordState < BaseService
  attr_reader :participant_profile_id, :school_id, :appropriate_body_id, :delivery_partner_id, :induction_record_id

  RECORD_STATES = {
    "different_trn" => "different_trn",
    "request_for_details_delivered" => "request_for_details_delivered",
    "request_for_details_failed" => "request_for_details_failed",
    "request_for_details_submitted" => "request_for_details_submitted",
    "validation_not_started" => "validation_not_started",
    "internal_error" => "internal_error",
    "tra_record_not_found" => "tra_record_not_found",
    "checks_not_complete" => "checks_not_complete",
    "active_flags" => "active_flags",
    "not_allowed" => "not_allowed",
    "duplicate_profile" => "duplicate_profile",
    "not_qualified" => "not_qualified",
    "exempt_from_induction" => "exempt_from_induction",
    "previous_induction" => "previous_induction",
    "no_induction_start" => "no_induction_start",
    "active_mentoring_ero" => "active_mentoring_ero",
    "active_mentoring" => "active_mentoring",
    "not_yet_mentoring_ero" => "not_yet_mentoring_ero",
    "not_yet_mentoring" => "not_yet_mentoring",
    "no_longer_involved" => "no_longer_involved",
    "leaving" => "leaving",
    "left" => "left",
    "joining" => "joining",
    "withdrawn_programme" => "withdrawn_programme",
    "withdrawn_training" => "withdrawn_training",
    "deferred_training" => "deferred_training",
    "completed_training" => "completed_training",
    "registered_for_fip_no_partner" => "registered_for_fip_no_partner",
    "active_fip_training" => "active_fip_training",
    "registered_for_fip_training" => "registered_for_fip_training",
    "registered_for_cip_training" => "registered_for_cip_training",
    "active_cip_training" => "active_cip_training",
    "active_diy_training" => "active_diy_training",
    "registered_for_diy_training" => "registered_for_diy_training",
    "not_registered_for_training" => "not_registered_for_training",
  }.freeze

  Record = Struct.new(
    :participant_profile_id,
    :induction_record_id,
    :school_id,
    :lead_provider_id,
    :delivery_partner_id,
    :appropriate_body_id,
    :changed_at,
    :validation_state,
    :training_eligibility_state,
    :fip_funding_eligibility_state,
    :mentoring_state,
    :training_state,
    :record_state,
    keyword_init: true,
  ) do
    def validation_status_valid?
      validation_state == "valid"
    end
  end

  def call
    result = ActiveRecord::Base.connection.execute(query)

    Record.new(**result.first)
  end

  def is_record_state?(state)
    call.record_state == state
  end

private

  def initialize(participant_profile:, induction_record: nil, delivery_partner: nil, appropriate_body: nil, school: nil)
    unless participant_profile.is_a? ParticipantProfile
      raise ArgumentError, "Expected a ParticipantProfile, got #{participant_profile.class}"
    end

    @participant_profile_id = participant_profile.id

    if participant_profile.ecf?
      unless induction_record.nil? || induction_record.is_a?(InductionRecord)
        raise ArgumentError, "Expected an InductionRecord, got #{induction_record.class}"
      end

      unless delivery_partner.nil? || delivery_partner.is_a?(DeliveryPartner)
        raise ArgumentError, "Expected a DeliveryPartner, got #{delivery_partner.class}"
      end

      unless appropriate_body.nil? || appropriate_body.is_a?(AppropriateBody)
        raise ArgumentError, "Expected a AppropriateBody, got #{appropriate_body.class}"
      end

      unless school.nil? || school.is_a?(School)
        raise ArgumentError, "Expected a School, got #{school.class}"
      end
    end

    @induction_record_id = induction_record&.id
    @delivery_partner_id = delivery_partner&.id
    @appropriate_body_id = appropriate_body&.id
    @school_id = school&.id
  end

  def query
    <<~SQL
      WITH
        mentee_counts as (#{mentee_counts}),
        latest_email_status_per_participant as (#{latest_email_status_per_participant}),
        individual_training_record_states as (#{individual_training_record_states})
      #{final_grouping}
    SQL
  end

  def mentee_counts
    <<~SQL
      SELECT
          "induction_records"."mentor_profile_id",
          count(*) as total
      FROM "induction_records"
      WHERE
          "induction_records"."mentor_profile_id" = '#{participant_profile_id}'
      GROUP BY
          "induction_records"."mentor_profile_id",
          "induction_records"."participant_profile_id"
    SQL
  end

  def latest_email_status_per_participant
    <<~SQL
      SELECT
          DISTINCT ON (ea.object_id) object_id,
          e.updated_at,
          e.status
      FROM
          emails e
      INNER JOIN
          email_associations ea ON e.id = ea.email_id
      WHERE
          'request_for_details' = ANY (e.tags)
      AND
          ea.object_type = 'ParticipantProfile'
      AND
          ea.object_id = '#{participant_profile_id}'
      ORDER BY
          ea.object_id,
          e.created_at DESC
    SQL
  end

  def individual_training_record_states
    <<~SQL
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
                  "latest_email_status_per_participant"."updated_at"
              ) AS changed_at,

          CASE
              WHEN "ecf_participant_eligibilities"."status" = 'manual_check' AND "ecf_participant_eligibilities"."reason" = 'different_trn'
                  THEN 'different_trn'
              WHEN "teacher_profiles"."trn" IS NULL AND "ecf_participant_validation_data" IS NULL
                  THEN
                  CASE
                      WHEN "latest_email_status_per_participant"."status" = 'delivered'
                          THEN 'request_for_details_delivered'
                      WHEN "latest_email_status_per_participant"."status" IN ('permanent-failure', 'technical-failure', 'temporary-failure')
                          THEN 'request_for_details_failed'
                      WHEN "latest_email_status_per_participant"."status" = 'submitted'
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
                              WHEN "ecf_participant_eligibilities"."reason" = 'previous_participation'
                                  THEN 'active_mentoring_ero'
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
               LEFT OUTER JOIN "latest_email_status_per_participant"
                               ON "participant_profiles"."id" = "latest_email_status_per_participant"."object_id"
               LEFT OUTER JOIN "mentee_counts"
                               ON "mentee_counts"."mentor_profile_id" = "participant_profiles"."id"

      WHERE
        #{individual_training_record_state_conditions}
    SQL
  end

  def individual_training_record_state_conditions
    conditions = [ParticipantProfile.arel_table[:id].eq(participant_profile_id)].tap do |c|
      c << SchoolCohort.arel_table[:school_id].eq(school_id) if school_id.present?
      c << InductionRecord.arel_table[:id].eq(induction_record_id) if induction_record_id.present?
      c << SchoolCohort.arel_table[:appropriate_body_id].eq(appropriate_body_id) if appropriate_body_id.present?
      c << Partnership.arel_table[:delivery_partner_id].eq(delivery_partner_id) if delivery_partner_id.present?
    end

    conditions.inject(&:and).to_sql
  end

  def final_grouping
    <<~SQL
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
                                                                                                      'ineligible_ero_primary',
                                                                                                      'ineligible_ero_secondary'
                                                                                                      )
                  THEN "individual_training_record_states"."fip_funding_eligibility_state"
              WHEN "individual_training_record_states"."participant_profile_type" = 'ParticipantProfile::Mentor'
                  THEN "individual_training_record_states"."mentoring_state"
              ELSE
                  "individual_training_record_states"."training_state"
              END as "record_state"

      FROM individual_training_record_states

      WHERE
          "individual_training_record_states"."participant_profile_id" = '#{participant_profile_id}'

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
    SQL
  end
end
