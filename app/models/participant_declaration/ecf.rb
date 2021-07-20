# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  delegate :lead_provider, to: :cpd_lead_provider

  scope :count_active_ects_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).ect.count }
  scope :count_active_mentors_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).mentor.count }
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
end
