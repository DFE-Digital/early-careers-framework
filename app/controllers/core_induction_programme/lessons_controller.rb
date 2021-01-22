# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  def show
    @lesson = CourseLesson.find(params[:lesson_id])
  end
end
