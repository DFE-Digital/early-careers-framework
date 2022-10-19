# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class ECF < ParticipantProfile
    self.ignored_columns = %i[school_id]
    VALID_EVIDENCE_HELD = %w[training-event-attended self-study-material-completed other].freeze
    COURSE_IDENTIFIERS = %w[ecf-mentor ecf-induction].freeze

    belongs_to :school_cohort
    belongs_to :core_induction_programme, optional: true

    has_one :school, through: :school_cohort
    has_one :cohort, through: :school_cohort

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

    def completed_validation_wizard?
      ecf_participant_eligibility.present? || ecf_participant_validation_data.present?
    end

    def contacted_for_info?
      ecf_participant_validation_data.nil?
    end

    def current_induction_record
      induction_records.current&.latest
    end

    def current_induction_programme
      induction_records.current&.latest&.induction_programme
    end

    def latest_induction_record_for(cpd_lead_provider:)
      induction_records
        .joins(induction_programme: { partnership: { lead_provider: [:cpd_lead_provider] } })
        .where(induction_programmes: { partnerships: { lead_providers: { cpd_lead_provider: } } })
        .latest
    end

    def ecf?
      true
    end

    delegate :ineligible_but_not_duplicated_or_previously_participated?,
             to: :ecf_participant_eligibility,
             allow_nil: true

    def fundable?
      ecf_participant_eligibility&.eligible_status?
    end

    def manual_check_needed?
      ecf_participant_eligibility&.manual_check_status? ||
        (ecf_participant_validation_data.present? && ecf_participant_eligibility.nil?)
    end

    def policy_class
      ParticipantProfile::ECFPolicy
    end

    def relevant_induction_record(lead_provider:)
      induction_records
        .joins(induction_programme: { school_cohort: [:cohort], partnership: [:lead_provider] })
        .where(induction_programme: { partnerships: { lead_provider: } })
        .where(induction_programme: { school_cohorts: { cohort: Cohort.where(start_year: 2021..) } })
        .order(start_date: :desc)
        .first
    end
    alias_method :record_to_serialize_for, :relevant_induction_record

    def schedule_for(cpd_lead_provider:)
      lead_provider = cpd_lead_provider.lead_provider

      induction_records
        .joins(induction_programme: { partnership: [:lead_provider] })
        .where(induction_programmes: { partnerships: { lead_provider: } })
        .latest
        .schedule
    end

    def withdrawn_for?(cpd_lead_provider:)
      !!latest_induction_record_for(cpd_lead_provider:)&.training_status_withdrawn?
    end

    def deferred_for?(cpd_lead_provider:)
      !!latest_induction_record_for(cpd_lead_provider:)&.training_status_deferred?
    end

  private

    def update_analytics
      Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile: self) if saved_changes?
    end

    def sync_status_with_induction_record
      induction_record = induction_records.latest
      induction_record&.update!(induction_status: status) if saved_change_to_status?
      induction_record&.update!(mentor_profile:) if saved_change_to_mentor_profile_id?
    end
  end
end

require "participant_profile/ect"
require "participant_profile/mentor"
