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
    if @school_cohorts.empty?
      redirect_to schools_choose_programme_path(cohort_id: Cohort.active_registration_cohort.start_year)
    end
  end

  def set_up_new_cohort?
    @school.school_cohorts.find_by(cohort: Cohort.active_registration_cohort).blank?
  end

  def previous_school_cohort
    @school.school_cohorts.find_by(cohort: Cohort.active_registration_cohort.previous)
  end

  def school_cohort_lead_provider_name(school_cohort)
    return school_cohort.lead_provider.name if school_cohort.lead_provider.present?
    return "To be confirmed" if school_cohort.default_induction_programme&.lead_provider_to_be_confirmed?
    return school_cohort.previous_lead_provider&.name || "To be confirmed"
  end

  def school_cohort_delivery_partner_name(school_cohort)
    return school_cohort.delivery_partner.name if school_cohort.delivery_partner.present?
    return "To be confirmed" if school_cohort.default_induction_programme&.delivery_partner_to_be_confirmed?
    return school_cohort.previous_delivery_partner&.name || "To be confirmed"
  end

  helper_method :set_up_new_cohort?, :previous_school_cohort, :school_cohort_lead_provider_name, :school_cohort_delivery_partner_name
end
