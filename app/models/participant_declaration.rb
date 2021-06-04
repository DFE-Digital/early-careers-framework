# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  include Concerns::ParticipantDeclarationEventRecorder
  belongs_to :lead_provider
  belongs_to :early_career_teacher_profile

  scope :for_lead_provider, ->(lead_provider) { where(lead_provider: lead_provider) }
  scope :active_for_lead_provider, ->(lead_provider) { active.for_lead_provider(lead_provider) }
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
  scope :count_active_for_lead_provider_between, ->(lead_provider, start_date, end_date) { declared_as_between(start_date, end_date).count_active_for_lead_provider(lead_provider) }
end
