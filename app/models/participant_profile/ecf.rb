# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  self.ignored_columns = %i[school_id]

  belongs_to :school_cohort
  belongs_to :core_induction_programme, optional: true

  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort
  has_one :ecf_participant_eligibility, foreign_key: :participant_profile_id

  def completed_validation_wizard?
    ecf_participant_eligibility.present? || ecf_participant_validation_data.present?
  end
end
