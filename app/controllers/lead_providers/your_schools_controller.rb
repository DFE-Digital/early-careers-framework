# frozen_string_literal: true

module LeadProviders
  class YourSchoolsController < ::LeadProviders::BaseController
    before_action :set_lead_provider

    def index
      @cohorts ||= @lead_provider.cohorts
      @selected_cohort = if params[:selected_cohort_id]
                           Cohort.find(params[:selected_cohort_id])
                         else
                           Cohort.find_by(start_year: Time.zone.today.year)
                         end

      @school_search_form = SchoolSearchForm.new(*form_params_index)
      @school_search_form.cohort_year = @selected_cohort.start_year
      @school_search_form.lead_provider_id = @lead_provider.id
      @school_search_form.with_school_partnerships = true

      @schools = @school_search_form.find_schools(params[:page])
    end

    def create
      redirect_to lead_providers_your_schools_path(*form_params_post)
    end

    def form_params_index
      params.permit(*school_search_params)
    end

    def form_params_post
      params.require(:school_search_form).permit(*school_search_params)
    end

    def school_search_params
      %i[
        school_name
        cohort_year
        lead_provider_id
        selected_cohort_id
      ]
    end

    def set_lead_provider
      @lead_provider = @current_user&.lead_provider
    end
  end
end
