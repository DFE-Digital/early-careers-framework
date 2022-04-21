# frozen_string_literal: true

module LeadProviders
  class PartnershipsController < ::LeadProviders::BaseController
    before_action :set_lead_provider

    def show
      @partnership = Partnership
        .includes(:cohort, :delivery_partner, :school)
        .where(lead_provider: @lead_provider)
        .find(params[:id])
      @school = @partnership.school
      @selected_cohort = @partnership.cohort
      @delivery_partner = @partnership.delivery_partner
    end

    def active
      @selected_cohort = params[:cohort] ? @lead_provider.cohorts.find_by(start_year: params[:cohort]) : Cohort.current

      @schools = @lead_provider.active_partnerships.where(cohort: @selected_cohort).includes(:school, :delivery_partner)

      respond_to do |format|
        format.csv do
          send_data Api::V1::PartnershipCsvSerializer.new(@schools).call, filename: "schools-#{@selected_cohort.start_year}.csv"
        end
      end
    end

  private

    def set_lead_provider
      @lead_provider = current_user.lead_provider
    end
  end
end
