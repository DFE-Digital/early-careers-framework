# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  belongs_to :npq_lead_provider, through: :cpd_lead_provider
end
