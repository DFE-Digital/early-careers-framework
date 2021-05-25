# frozen_string_literal: true

module LeadProviders
  class PartnershipsController < ::LeadProviders::BaseController
    def show
      @partnership = Partnership.find(params[:id])
      @school = @partnership.school
      @selected_cohort = @partnership.cohort
    end
  end
end
