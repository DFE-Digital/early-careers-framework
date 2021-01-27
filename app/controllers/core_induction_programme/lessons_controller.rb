# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  include Pundit

  after_action :verify_authorized, except: :show
  before_action :authenticate_user!, except: :show

  def show
    @course_lesson = CourseLesson.find(params[:lesson_id])
  end

  def edit
    @lesson = CourseLesson.find(params[:lesson_id])
    authorize @lesson

    @lesson_preview = params[:lesson_preview] || @lesson.content
    @course_lesson = Govspeak::Document.new(@lesson_preview, options: { allow_extra_quotes: true }).to_html
  end

  def update
    @lesson = CourseLesson.find(params[:lesson_id])
    authorize @lesson

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
