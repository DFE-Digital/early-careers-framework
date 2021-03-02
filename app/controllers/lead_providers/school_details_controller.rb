# frozen_string_literal: true

module LeadProviders
  class SchoolDetailsController < ::LeadProviders::BaseController
    def show
      @school = School.find(params[:id])
      @selected_cohort = Cohort.find(params[:selected_cohort_id])
    end
  end
end

