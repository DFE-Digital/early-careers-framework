# frozen_string_literal: true

require "govspeak"

class SchoolSearchController < ApplicationController
  def show
    @search_schools_form = SearchSchoolsForm.new(*form_params_show)
    @schools = @search_schools_form.find_schools
  end

  def create
    redirect_to school_search_path(*form_params_post)
  end

private

  def form_params_show
    params.permit(*search_schools_params)
  end

  def form_params_post
    params.require(:search_schools_form).permit(*search_schools_params)
  end

  def search_schools_params
    [
      :school_name,
      :location,
      :search_distance,
      :search_distance_unit,
      characteristics: [],
      partnership: [],
    ]
  end
end
