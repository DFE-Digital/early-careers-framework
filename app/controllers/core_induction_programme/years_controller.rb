# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  def show
    @course_years = CourseYear.where(lead_provider: params[:id])
  end
end
