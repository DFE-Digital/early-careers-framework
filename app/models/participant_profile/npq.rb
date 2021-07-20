# frozen_string_literal: true

class ParticipantProfile::NPQ < ParticipantProfile
  belongs_to :school, optional: true

  has_one :validation_data, class_name: "NPQValidationData", foreign_key: :id, dependent: :destroy

  self.validation_steps = %i[identity decision]

  def npq?
    true
  end

  def approved?
    validation_decision(:decision).approved?
  end

  def rejected?
    decision = validation_decision(:decision)
    decision.persisted? && !decision.approved?
  end

  def participant_type
    :npq
  end
end
