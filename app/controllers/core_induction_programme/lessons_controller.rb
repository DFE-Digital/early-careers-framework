# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  def show
    @course_lesson = CourseLesson.find(params[:lesson_id])
  end

  def create; end

  def edit
    @lesson_preview = params[:lesson_preview] || CourseLesson.find(params[:lesson_id]).content
    @course_lesson = Govspeak::Document.new(@lesson_preview, options: { allow_extra_quotes: true }).to_html
  end

  def update
    @lesson = CourseLesson.find(params[:lesson_id])
    respond_to do |format|
      if params[:commit] == "Save changes"
        @lesson.update!(content: params[:lesson_preview])
        format.html { redirect_to cip_years_modules_lessons_url }
      else
        @lesson_preview = params[:lesson_preview]
        @course_lesson = Govspeak::Document.new(@lesson_preview, options: { allow_extra_quotes: true }).to_html
        format.html { render action: "edit" }
      end
    end
  end
end
