# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  before_action :set_school_cohorts, only: :show, unless: -> { FeatureFlag.active?(:multiple_cohorts) }
  before_action :set_multi_cohorts, only: :show, if: -> { FeatureFlag.active?(:multiple_cohorts) }
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    @pagy, @schools = pagy(current_user
                      .induction_coordinator_profile
                      .schools
                      .order(:name),
                           page: params[:page],
                           items: 10)
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
      redirect_to schools_choose_programme_path(cohort_id: Cohort.current.start_year)
    end
  end

  def set_multi_cohorts
    @school = active_school

    @school_cohorts = @school.school_cohorts.dashboard_cohorts
    # FIXME: need to call this when no school_cohorts for the right registration window
    # redirect_to schools_choose_programme_path(cohort_id: Cohort.current.start_year)
  end

end
