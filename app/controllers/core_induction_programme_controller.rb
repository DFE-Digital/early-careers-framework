# frozen_string_literal: true

class CoreInductionProgrammeController < ApplicationController
  def show
    @course_years = CourseYear.all
  end
end
