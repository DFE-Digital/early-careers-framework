# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  self.ignored_columns = %i[school_id]

  belongs_to :school_cohort
  belongs_to :core_induction_programme, optional: true

  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort
  has_one :ecf_participant_eligibility, foreign_key: :participant_profile_id
  has_one :ecf_participant_validation_data, foreign_key: :participant_profile_id

  def completed_validation_wizard?
    ecf_participant_eligibility.present? || ecf_participant_validation_data.present?
  end

  def manual_check_needed?
    ecf_participant_eligibility&.manual_check_status? ||
      (ecf_participant_validation_data.present? && ecf_participant_eligibility.nil?)
  end
end
