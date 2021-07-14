# frozen_string_literal: true

module LeadProviders
  class PartnershipsController < ::LeadProviders::BaseController
    def show
      @partnership = Partnership
        .includes(:cohort, :delivery_partner, :school)
        .where(lead_provider: current_user.lead_provider)
        .find(params[:id])
      @school = @partnership.school
      @selected_cohort = @partnership.cohort
      @delivery_partner = @partnership.delivery_partner
    end
  end
end
