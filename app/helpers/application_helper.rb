# frozen_string_literal: true

module ApplicationHelper
  def profile_dashboard_path(user)
    if user.admin?
      admin_schools_path
    elsif user.finance?
      finance_lead_providers_path
    elsif user.sit_mentor?
      sit_mentor_path(user)
    elsif user.induction_coordinator?
      induction_coordinator_dashboard_path(user)
    elsif user.mentor? || user.early_career_teacher?
      participant_start_path(user)
    else
      dashboard_path
    end
  end

  def data_layer
    @data_layer ||= build_data_layer
  end

  def build_data_layer
    analytics_data = AnalyticsDataLayer.new
    analytics_data.add_user_info(current_user) if current_user
    analytics_data.add_school_info(assigns["school"]) if assigns["school"]
    analytics_data
  end

  def induction_coordinator_dashboard_path(user)
    return schools_dashboard_index_path if user.schools.count > 1

    school = user.induction_coordinator_profile.schools.first
    return advisory_schools_choose_programme_path(school_id: school.slug) unless school.chosen_programme?(Cohort.current)

    schools_dashboard_path(school_id: school.slug)
  end

  def participant_start_path(user)
    if FeatureFlag.active?(:participant_validation, for: user.teacher_profile&.participant_profiles&.ecf&.active&.first&.school)
      participants_validation_start_path
    else
      dashboard_path
    end
  end

private

  def sit_mentor_path(user)
    if FeatureFlag.active?(:participant_validation, for: user.teacher_profile&.participant_profiles&.ecf&.active&.first&.school)
      profile = user.participant_profiles.active.mentors.first
      return participant_start_path(user) unless profile&.completed_validation_wizard?
    end

    induction_coordinator_dashboard_path(user)
  end
end
