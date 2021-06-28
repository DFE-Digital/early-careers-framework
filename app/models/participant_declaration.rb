# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_one :profile_declaration
  belongs_to :lead_provider

  # Basic scopes for local fields
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
end
