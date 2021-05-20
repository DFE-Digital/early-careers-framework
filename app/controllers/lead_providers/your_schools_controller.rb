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

      @schools = School.partnered_with_lead_provider(@lead_provider.id, @selected_cohort.start_year)
        .includes(:early_career_teachers)
        .order(:name)

      @total_provider_schools = @schools.count

      @query = params[:query]
      if @query.present?
        @schools = @schools.search_by_name_or_urn_or_delivery_partner_for_year(@query, @selected_cohort.start_year)
      end

      @schools = @schools.page(params[:page]).per(20)
    end

  private

    def set_lead_provider
      @lead_provider = current_user&.lead_provider
    end
  end
end
