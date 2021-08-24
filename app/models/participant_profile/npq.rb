# frozen_string_literal: true

class ParticipantProfile::NPQ < ParticipantProfile
  self.ignored_columns = %i[mentor_profile_id school_cohort_id]
  belongs_to :school, optional: true
  belongs_to :npq_course, optional: true

  has_one :validation_data, class_name: "NPQValidationData", foreign_key: :id, dependent: :destroy

  self.validation_steps = %i[identity decision].freeze

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

  def fundable?
    false
  end
end
