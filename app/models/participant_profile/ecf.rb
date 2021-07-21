# frozen_string_literal: true

class ParticipantProfile::Ecf < ParticipantProfile
  self.ignored_columns = %i[school_id]

  belongs_to :school_cohort
  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort
end
