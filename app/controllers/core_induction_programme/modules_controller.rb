# frozen_string_literal: true

class CoreInductionProgramme::ModulesController < ApplicationController
  def show
    @course_module = CourseModule.includes(:course_lessons).find(params[:module_id])
  end
end
