# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :early_career_teacher_profile

  scope :for_lead_provider, ->(lead_provider) { where(lead_provider: lead_provider) }
  scope :active_for_lead_provider, ->(lead_provider) { active.for_lead_provider(lead_provider) }
  scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
  scope :count_active_for_lead_provider_between, ->(lead_provider, start_date, end_date) { declared_as_between(start_date, end_date).count_active_for_lead_provider(lead_provider) }
  scope :count_active_uplift_for_lead_provider, ->(lead_provider) { active_uplift_for_lead_provider(lead_provider).count }

  scope :unique_early_career_teacher_profile_id, -> { select(:early_career_teacher_profile_id).distinct }
  scope :active, -> { where(declaration_type: "started").order(declaration_date: "desc").unique_early_career_teacher_profile_id }
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :active_uplift_for_lead_provider, lambda { |lead_provider|
    active_for_lead_provider(lead_provider).joins(:early_career_teacher_profile)
      .where("early_career_teacher_profiles.sparsity_uplift OR early_career_teacher_profiles.pupil_premium_uplift")
  }
end
