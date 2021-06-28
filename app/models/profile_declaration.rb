# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  delegated_type :declarable, types: %w[EarlyCareerTeacherProfile MentorProfile]
  belongs_to :participant_declaration
  belongs_to :lead_provider

  # Helper scopes
  scope :for_lead_provider, ->(lead_provider) { where(lead_provider: lead_provider) }

  scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_id }
  scope :started, -> { unique_id.merge(ParticipantDeclaration.for_declaration("started").order(declaration_date: "desc")) }
  scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_id }

  # Declaration aggregation scopes
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
  scope :count_active_uplift_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).uplift.count }
end
