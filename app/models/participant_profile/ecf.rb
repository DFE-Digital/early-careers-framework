# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class ECF < ParticipantProfile
    self.ignored_columns = %i[school_id]

    CURRENT_START_TERM_OPTIONS = %w[spring_2022 summer_2022].freeze

    belongs_to :school_cohort
    belongs_to :core_induction_programme, optional: true

    has_one :school, through: :school_cohort
    has_one :cohort, through: :school_cohort
    has_one :ecf_participant_eligibility, foreign_key: :participant_profile_id
    has_one :ecf_participant_validation_data, foreign_key: :participant_profile_id

    belongs_to :mentor_profile, -> { where(id: 0) }, class_name: "Mentor", optional: true
    has_one :mentor, through: :mentor_profile, source: :user

    scope :ineligible_status, -> { joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible }).where.not(ecf_participant_eligibility: { reason: %i[previous_participation duplicate_profile] }) }
    scope :eligible_status, lambda {
      joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :eligible })
        .or(joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible, reason: %i[previous_participation duplicate_profile] }))
    }
    scope :current_cohort, -> { joins(:school_cohort).where(school_cohort: { cohort_id: Cohort.current.id }) }
    scope :contacted_for_info, -> { where.missing(:ecf_participant_validation_data) }
    scope :details_being_checked, -> { joins(:ecf_participant_validation_data).left_joins(:ecf_participant_eligibility).where("ecf_participant_eligibilities.id IS NULL OR ecf_participant_eligibilities.status = 'manual_check'") }

    enum profile_duplicity: {
      single: "single",
      primary: "primary",
      secondary: "secondary",
    }, _suffix: "profile"

    after_save :update_analytics
    after_update :sync_status_with_induction_record

    def current_induction_record
      induction_records.current&.latest
    end

    def current_induction_programme
      induction_records.current&.latest&.induction_programme
    end

    def ecf?
      true
    end

    def completed_validation_wizard?
      ecf_participant_eligibility.present? || ecf_participant_validation_data.present?
    end

    def manual_check_needed?
      ecf_participant_eligibility&.manual_check_status? ||
        (ecf_participant_validation_data.present? && ecf_participant_eligibility.nil?)
    end

    def fundable?
      ecf_participant_eligibility&.eligible_status?
    end

    def policy_class
      ParticipantProfile::ECFPolicy
    end

    def relevant_induction_record(lead_provider:)
      induction_records
        .joins(induction_programme: { school_cohort: [:cohort], partnership: [:lead_provider] })
        .where(induction_programme: { partnerships: { lead_provider: lead_provider } })
        .where(induction_programme: { school_cohorts: { cohort: Cohort.current } })
        .order(start_date: :desc)
        .first
    end

  private

    def update_analytics
      Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile: self) if saved_changes?
    end

    def sync_status_with_induction_record
      induction_record = induction_records.latest
      induction_record&.update!(induction_status: status) if saved_change_to_status?
      induction_record&.update!(mentor_profile: mentor_profile) if saved_change_to_mentor_profile_id?
    end
  end
end

require "participant_profile/ect"
require "participant_profile/mentor"
