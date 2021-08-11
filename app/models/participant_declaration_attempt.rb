# frozen_string_literal: true

class ParticipantDeclarationAttempt < ApplicationRecord
  belongs_to :cpd_lead_provider
  belongs_to :user
  belongs_to :participant_declaration, optional: true
end
