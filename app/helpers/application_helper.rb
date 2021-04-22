# frozen_string_literal: true

module ApplicationHelper
  def profile_dashboard_path(user)
    if user.admin?
      admin_schools_path
    elsif user.induction_coordinator?
      induction_coordinator_dashboard_path(user)
    else
      dashboard_path
    end
  end

private

  def induction_coordinator_dashboard_path(user)
    school = user.induction_coordinator_profile.schools.first

    return advisory_schools_choose_programme_path unless school.chosen_programme?(Cohort.current)

    schools_dashboard_path
  end
end
