# frozen_string_literal: true

class Schools::BaseController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :ensure_school_user
  before_action :check_cohort_year
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

  layout "school_cohort"

private

  # Redirect to school dashboard if the user is requesting an action for a future cohort not for a pilot school.
  def check_cohort_year
    return if params[:cohort_id].blank?

    max_cohort_year = [
      Cohort.latest&.start_year,
      Cohort.next&.start_year,
      Cohort.active_registration_cohort.start_year.to_i +
        (FeatureFlag.active?(:cohortless_dashboard, for: active_school) ? 1 : 0),
    ].compact.min

    redirect_to schools_dashboard_path if params[:cohort_id].to_i > max_cohort_year
  end

  def ensure_school_user
    raise Pundit::NotAuthorizedError, I18n.t(:forbidden) unless current_user.induction_coordinator?

    authorize(active_school, :show?) if active_school.present?
  end

  def active_school
    School.friendly.find(params[:school_id]) if params[:school_id].present?
  end

  def active_cohort
    Cohort.find_by(start_year: params[:cohort_id]) if params[:cohort_id].present?
  end

  def set_school
    @school ||= policy_scope(School).friendly.find(params[:school_id]) if params[:school_id].present?
  end

  def set_school_cohort(cohort: active_cohort)
    @cohort = cohort
    @school = active_school
    @school_cohort = policy_scope(SchoolCohort).find_by(cohort: @cohort, school: @school)
    redirect_to schools_choose_programme_path(cohort_id: @cohort) unless @school_cohort
  end

  def start_year
    Cohort.active_registration_cohort.start_year
  end
end
