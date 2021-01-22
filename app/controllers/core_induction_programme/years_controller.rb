# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  def show
    @course_year = CourseYear.includes(:course_modules).find(params[:year_id])
  end
end
