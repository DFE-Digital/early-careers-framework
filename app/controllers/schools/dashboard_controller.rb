# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  before_action :set_school_cohorts, only: :show
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @schools = current_user.induction_coordinator_profile.schools
                           .order(:name)
                           .page(params[:page])
                           .per(10)
  end

  def show
    @partnership = @school.partnerships.active.find_by(cohort: @cohort_list)

    if @partnership&.in_challenge_window?
      @report_mistake_link = challenge_partnership_path(partnership: @partnership)
      @mistake_link_expiry = @partnership.challenge_deadline&.strftime("%d/%m/%Y")
    end
  end

private

  def set_school_cohorts
    @school = active_school

    @cohort_list = [Cohort.current]
    @school_cohorts = @school.school_cohorts.where(cohort: @cohort_list)

    # This will need to be updated when more than one cohort is supported
    unless @school_cohorts[0]
      redirect_to schools_choose_programme_path
    end
  end
end
