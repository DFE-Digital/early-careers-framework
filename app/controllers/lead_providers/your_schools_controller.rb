# frozen_string_literal: true

module LeadProviders
  class YourSchoolsController < ::LeadProviders::BaseController
    before_action :set_lead_provider

    def index
      @cohorts ||= @lead_provider.cohorts

      # Don't break old URLs
      if params[:selected_cohort_id]
        redirect_to cohort: params[:selected_cohort_id]
        return
      end

      @selected_cohort = params[:cohort] ? @cohorts.find_by(start_year: params[:cohort]) : Cohort.current

      @partnerships = Partnership
        .includes(:delivery_partner, :cohort, :school)
        .order("schools.name")
        .where(
          cohort: @selected_cohort,
          lead_provider: @lead_provider,
        )

      @total_provider_schools = @partnerships.count

      @query = params[:query]
      @partnerships = @partnerships.ransack(
        school_name_or_school_urn_or_delivery_partner_name_cont: @query,
      ).result
    end

  private

    def set_lead_provider
      @lead_provider = current_user&.lead_provider
    end
  end
end
