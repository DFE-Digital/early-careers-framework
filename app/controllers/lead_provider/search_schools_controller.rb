# frozen_string_literal: true

class LeadProvider::SearchSchoolsController < LeadProvider::BaseController
  def show
    skip_policy_scope
    skip_authorization

    @school_search_form = SchoolSearchForm.new(*form_params_show)
    @schools = @school_search_form.find_schools(params[:page])
  end

  def create
    skip_policy_scope
    skip_authorization

    redirect_to lead_provider_search_schools_path(*form_params_post)
  end

private

  def form_params_show
    params.permit(*school_search_params)
  end

  def form_params_post
    params.require(:school_search_form).permit(*school_search_params)
  end

  def school_search_params
    [
      :school_name,
      :location,
      :search_distance,
      :search_distance_unit,
      characteristics: [],
      partnership: [],
    ]
  end

  def set_lead_provider
    @lead_provider = @current_user&.lead_provider
  end
end
