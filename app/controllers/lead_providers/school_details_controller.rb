# frozen_string_literal: true

module LeadProviders
  class SchoolDetailsController < ::LeadProviders::BaseController
    def show
      @school = find_school
      @selected_cohort = selected_cohort_or_current
    end

  private

    def selected_cohort_or_current
      Cohort.find_by(id: params[:selected_cohort_id]) || Cohort.current
    end

    def find_school
      year = selected_cohort_or_current.start_year
      School.eligible.partnered_with_lead_provider(current_user.lead_provider.id, year).find(params[:id])
    end
  end
end
