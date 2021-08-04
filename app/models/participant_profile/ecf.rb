# frozen_string_literal: true

class ParticipantProfile::ECF < ParticipantProfile
  self.ignored_columns = %i[school_id]

  belongs_to :school_cohort
  belongs_to :core_induction_programme, optional: true

  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort
end
