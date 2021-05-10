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
      search_scope = School.eligible

      search_scope = search_scope.partnered_with_lead_provider(current_user.lead_provider.id, year) if current_user.lead_provider?
      search_scope.find(params[:id])
    end
  end
end
