# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  self.abstract_class = true

  belongs_to :participant_declaration

  scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_id }
  scope :started, -> { unique_id.merge(ParticipantDeclaration.for_declaration("started").order(declaration_date: "desc")) }

  # Declaration aggregation scopes
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
end
