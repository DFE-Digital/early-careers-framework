# frozen_string_literal: true

class Schools::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_school_user
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

  helper_method :breadcrumbs

  layout "school_cohort"

private

  def ensure_school_user
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?

    authorize(active_school, :show?) if active_school.present?
  end

  def active_school
    School.friendly.find(params[:school_id])
  end

  def active_cohort
    Cohort.find_by(start_year: params[:cohort_id])
  end

  def set_school_cohort
    @school = active_school
    @cohort = active_cohort

    @school_cohort = policy_scope(SchoolCohort).find_by(
      cohort: @cohort,
      school: @school,
    )

    redirect_to advisory_schools_choose_programme_path unless @school_cohort
  end

  def breadcrumbs(*args)
    breadcrumbs = base_breadcrumbs
    breadcrumbs.merge!({ active_school.name => schools_dashboard_path }) if args.include?(:school)
    breadcrumbs.merge!({ "#{active_cohort.display_name} cohort" => schools_cohort_path }) if args.include?(:cohort)
    breadcrumbs
  end

  def base_breadcrumbs
    current_user.schools.count > 1 ? { "Manage your schools" => schools_dashboard_index_path } : {}
  end
end
