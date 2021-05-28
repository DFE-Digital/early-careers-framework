# frozen_string_literal: true

class ParticipationRecord < ApplicationRecord
  include Concerns::ParticipantRecordStateMachine
  belongs_to :early_career_teacher_profile
  belongs_to :lead_provider

  scope :active_for_lead_provider, ->(lead_provider) { active.where(lead_provider: lead_provider) }
end
