# frozen_string_literal: true

module LeadProviders
  class YourSchoolsController < ::LeadProviders::BaseController
    before_action :set_lead_provider

    def index
      @cohorts ||= @lead_provider.cohorts
      @selected_cohort = if params[:selected_cohort_id]
                           @cohorts.find(params[:selected_cohort_id])
                         else
                           @cohorts.find_by(start_year: Time.zone.today.year)
                         end

      @partnerships = Partnership
        .includes(school: :early_career_teachers)
        .order("schools.name")
        .where(
          cohort: @selected_cohort,
          lead_provider: @lead_provider,
        )

      @total_provider_schools = @partnerships.count

      @partnerships = @partnerships.ransack(
        school_name_or_school_urn_or_delivery_partner_name_cont: params[:query],
      ).result

      @partnerships = @partnerships.page(params[:page]).per(20)
    end

  private

    def set_lead_provider
      @lead_provider = current_user&.lead_provider
    end
  end
end
