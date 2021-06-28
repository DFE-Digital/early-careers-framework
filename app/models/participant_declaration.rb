# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  self.ignored_columns = %w[early_career_teacher_profile_id]

  belongs_to :lead_provider
  has_one :profile_declaration, as: :decloratable

  # Helper scopes
  scope :for_lead_provider, ->(lead_provider) { where(lead_provider: lead_provider) }
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
end
