# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  def show
    @course_year = CourseYear.includes(:course_modules).find(params[:id])
  end
end
