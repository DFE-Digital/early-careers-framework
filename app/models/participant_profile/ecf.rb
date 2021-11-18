# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  self.ignored_columns = %i[school_id]

  belongs_to :school_cohort
  belongs_to :core_induction_programme, optional: true

  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort
  has_one :ecf_participant_eligibility, foreign_key: :participant_profile_id
  has_one :ecf_participant_validation_data, foreign_key: :participant_profile_id

  scope :ineligible_status, -> { joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible }) }
  scope :eligible_status, lambda {
    joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :eligible })
                                       .or(joins(:ecf_participant_eligibility).where(ecf_participant_eligibility: { status: :ineligible, reason: :previous_participation }))
  }
  scope :current_cohort, -> { joins(:school_cohort).where(school_cohort: { cohort_id: Cohort.current.id }) }
  scope :contacted_for_info, -> { where.missing(:ecf_participant_validation_data) }
  scope :details_being_checked, -> { joins(:ecf_participant_validation_data).left_joins(:ecf_participant_eligibility).where("ecf_participant_eligibilities.id IS NULL OR ecf_participant_eligibilities.status = 'manual_check'") }

  enum profile_duplicity: {
    single: "single",
    primary: "primary",
    secondary: "secondary",
  }, _suffix: "profile"

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
end
