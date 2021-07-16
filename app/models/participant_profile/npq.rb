# frozen_string_literal: true

class ParticipantProfile::NPQ < ParticipantProfile
  self.ignored_columns = %i[mentor_profile_id]

  has_one :validation_data, class_name: "NPQValidationData", foreign_key: :id, dependent: :destroy

  def npq?
    true
  end

  def participant_type
    :npq
  end
end
