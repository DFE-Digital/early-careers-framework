# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  include Pundit
  include GovspeakHelper

  after_action :verify_authorized, except: :show
  before_action :authenticate_user!, except: :show
  before_action :load_and_authorize_course_lesson

  def show; end

  def edit
    @lesson_preview = params[:lesson_preview] || @course_lesson.content
    @html_content = content_to_html(@lesson_preview)
  end

  def update
    if params[:commit] == "Save changes"
      @course_lesson.update!(content: params[:lesson_preview])
      redirect_to cip_years_modules_lessons_url
    else
      @lesson_preview = params[:lesson_preview]
      @html_content = content_to_html(@lesson_preview)
      render action: "edit"
    end
  end

private

  def load_and_authorize_course_lesson
    @course_lesson = CourseLesson.find(params[:lesson_id])
    authorize @course_lesson
  end
end
