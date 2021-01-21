# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  def show
    single_lesson = CourseLesson.find(params[:id])
    @lesson = Govspeak::Document.new(single_lesson.content, options: { allow_extra_quotes: true }).to_html
  end
end
