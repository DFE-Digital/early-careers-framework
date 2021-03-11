# frozen_string_literal: true

class CoreInductionProgrammes::ProgressController < ApplicationController
  include Pundit
  include GovspeakHelper

  after_action :verify_authorized
  before_action :authenticate_user!
  before_action :load_course_lesson

  def update
    progress = CourseLessonProgress.find_or_create_by!(early_career_teacher_profile: @current_user.early_career_teacher_profile, course_lesson: @course_lesson)
    authorize progress
    if @current_user.early_career_teacher?
      unless params[:progress].include?("not_started")
        progress.update!(progress: params[:progress])
      end
    end
    redirect_to year_module_url(id: @course_lesson.course_module.id)
  end

private

  def load_course_lesson
    @course_lesson = CourseLesson.find(params[:lesson_id])
  end
end
