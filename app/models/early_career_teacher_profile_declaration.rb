# frozen_string_literal: true

class EarlyCareerTeacherProfileDeclaration < ProfileDeclaration
  belongs_to :early_career_teacher_profile

  scope :unique_id, -> { select(:early_career_teacher_profile_id).distinct }

  # Helper scopes
  # scope :started, -> { for_declaration("started").order(declaration_date: "desc").unique_early_career_teacher_profile_id }
  # scope :uplift, -> { joins(:early_career_teacher_profile).merge(EarlyCareerTeacherProfile.uplift) }
  # scope :unique_early_career_teacher_profile_id, -> { select(:early_career_teacher_profile_id).distinct }
  # scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_early_career_teacher_profile_id }
  #
  # # Declaration aggregation scopes
  # scope :count_active_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).count }
  # scope :count_active_uplift_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).uplift.count }
end
