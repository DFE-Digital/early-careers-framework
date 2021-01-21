# frozen_string_literal: true

class CoreInductionProgramme::ModulesController < ApplicationController
  def show
    @modules = CourseModule.where(course_year: params[:id])
    @lessons = CourseLesson.all
  end
end
