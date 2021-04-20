# frozen_string_literal: true

module ApplicationHelper
  def profile_dashboard_url(user)
    if user.admin?
      admin_schools_url
    elsif user.induction_coordinator?
      induction_coordinator_dashboard_url(user)
    else
      dashboard_url
    end
  end

private

  def induction_coordinator_dashboard_url(user)
    school = user.induction_coordinator_profile.schools.first

    return advisory_schools_choose_programme_url unless school.chosen_programme?(Cohort.current)

    schools_dashboard_url
  end
end
