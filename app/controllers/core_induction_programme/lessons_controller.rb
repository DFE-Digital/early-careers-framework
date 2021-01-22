# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  def show
    @course_lesson = CourseLesson.find(params[:lesson_id])
  end
end
