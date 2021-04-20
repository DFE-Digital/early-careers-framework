# frozen_string_literal: true

class Schools::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_school_user
  before_action :set_paper_trail_whodunnit
  after_action :verify_authorized
  after_action :verify_policy_scoped

private

  def ensure_school_user
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user.induction_coordinator?
  end

  def set_school_cohort
    @school = current_user.induction_coordinator_profile.schools.first
    @cohort = Cohort.find_by(start_year: params[:id] || params[:cohort_id])

    @school_cohort = policy_scope(SchoolCohort).find_by(
      cohort: @cohort,
      school: @school,
    )

    redirect_to advisory_schools_choose_programme_path unless @school_cohort
  end
end
