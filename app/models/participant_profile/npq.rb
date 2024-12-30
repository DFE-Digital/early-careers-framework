# frozen_string_literal: true

class ParticipantProfile::NPQ < ParticipantProfile
  # self.ignored_columns = %i[mentor_profile_id school_cohort_id]
  belongs_to :cohort, optional: true
  belongs_to :school, optional: true

  has_many :participant_declarations, class_name: "ParticipantDeclaration::NPQ", foreign_key: :participant_profile_id
end
