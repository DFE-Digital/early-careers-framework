# frozen_string_literal: true

class CoreInductionProgramme::LessonsController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized
  before_action :authenticate_user!, except: :show
  before_action :load_course_lesson

  def show
    if @current_user&.early_career_teacher?
      progress = CourseLessonProgress.find_or_create_by!(early_career_teacher_profile: @current_user.early_career_teacher_profile, course_lesson: @course_lesson)
      progress.in_progress! if progress.not_started?
    end
  end

  def edit; end

  def update
    if params[:commit] == "Save changes"
      @course_lesson.save!
      flash[:success] = "Your changes have been saved"
      redirect_to cip_year_module_lesson_url
    else
      render action: "edit"
    end
  end

private

  def load_course_lesson
    @course_lesson = CourseLesson.find(params[:id])
    authorize @course_lesson
    @course_lesson.assign_attributes(course_lesson_params)
  end

  def course_lesson_params
    params.permit(:content, :title)
  end
end
