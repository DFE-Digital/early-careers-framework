# frozen_string_literal: true

module SchoolBreadcrumbsHelper
  def breadcrumbs(active_school = nil, active_participant = nil)
    breadcrumbs = base_breadcrumbs
    breadcrumbs.merge!({ active_school.name => schools_dashboard_path(school_id: active_school) }) if active_school.present?
    if active_participant.present?
      if active_participant.mentor?
        breadcrumbs.merge!({ "Manage mentors" => school_mentors_path(school_id: active_school) })
      else
        breadcrumbs.merge!({ "Manage ECTs" => school_early_career_teachers_path(school_id: active_school) })
      end
    end

    breadcrumbs
  end

  def base_breadcrumbs
    current_user.schools.count > 1 ? { "Manage your schools" => schools_dashboard_index_path } : {}
  end
end
