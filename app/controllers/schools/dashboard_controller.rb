# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  before_action :set_school_cohorts, only: :show
  before_action :check_school_cohorts, only: :show
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
      @mistake_link_expiry = @partnership.challenge_deadline&.to_date&.to_fs(:govuk)
    end
  end

private

  def active_registration_cohort_visible?
    @school_cohorts.map(&:cohort_id).include?(Cohort.active_registration_cohort.id)
  end

  def check_school_cohorts
    if @school_cohorts.empty?
      redirect_to schools_choose_programme_path(cohort_id: Cohort.active_registration_cohort.start_year)
    end
  end

  def set_school_cohorts
    @school = active_school
    @school_cohorts = SchoolCohort.dashboard_for_school(school: @school,
                                                        latest_year: Dashboard::LatestManageableCohort.call(@school).start_year)
  end

  def set_up_new_cohort?
    active_registration_cohort_visible? && !@school.chosen_programme?(Cohort.active_registration_cohort)
  end

  def previous_school_cohort
    @school.school_cohorts.find_by(cohort: Cohort.active_registration_cohort.previous)
  end

  def previous_lead_provider(school_cohort)
    school = school_cohort.school
    previous_start_year = school_cohort.cohort.start_year - 1
    previous_school_cohort = school.school_cohorts.find_by(cohort: Cohort.find_by(start_year: previous_start_year))
    previous_school_cohort.lead_provider
  end

  def school_cohort_lead_provider_name(school_cohort)
    if school_cohort.lead_provider.present?
      school_cohort.lead_provider.name
    elsif school_cohort.default_induction_programme&.delivery_partner_to_be_confirmed?
      previous_lead_provider(school_cohort)&.name
    else
      "Your lead provider needs to confirm this with us"
    end
  end

  def school_cohort_delivery_partner_name(school_cohort)
    if school_cohort.delivery_partner.present?
      school_cohort.delivery_partner.name
    else
      "Your lead provider needs to confirm this with us"
    end
  end

  helper_method :set_up_new_cohort?, :previous_school_cohort, :school_cohort_lead_provider_name, :school_cohort_delivery_partner_name
end
