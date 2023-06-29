# frozen_string_literal: true

module SchoolBreadcrumbsHelper
  def breadcrumbs(active_school = nil, active_cohort = nil)
    breadcrumbs = base_breadcrumbs
    breadcrumbs.merge!({ active_school.name => schools_dashboard_path(school_id: active_school) }) if active_school.present?
    breadcrumbs.merge!({ "#{active_cohort.display_name} cohort" => schools_cohort_path(school_id: active_school, cohort_id: active_cohort) }) if active_cohort.present?
    breadcrumbs
  end

  def base_breadcrumbs
    current_user.schools.count > 1 ? { "Manage your schools" => schools_dashboard_index_path } : {}
  end
end
