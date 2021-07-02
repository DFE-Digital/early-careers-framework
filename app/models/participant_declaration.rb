# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_one :profile_declaration
  belongs_to :lead_provider
  belongs_to :user

  # Helper scopes
  scope :for_lead_provider, ->(lead_provider) { where(lead_provider: lead_provider) }
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }
  scope :started, -> { for_declaration("started").order(declaration_date: "desc").unique_id }
  scope :uplift, -> { joins(:profile_declaration).merge(ProfileDeclaration.uplift) }
  scope :unique_id, -> { select(:user_id).distinct }
  scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_id }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Declaration aggregation scopes
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
  scope :count_active_uplift_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).uplift.count }
end
