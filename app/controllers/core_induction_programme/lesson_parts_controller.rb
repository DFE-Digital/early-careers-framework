# frozen_string_literal: true

class CoreInductionProgramme::LessonPartsController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized
  before_action :authenticate_user!, except: :show
  before_action :load_course_lesson_part

  def show; end

  def edit; end

  def update
    if params[:commit] == "Save changes"
      @course_lesson_part.save!
      flash[:success] = "Your changes have been saved"
      redirect_to cip_year_module_lesson_part_url
    else
      render action: "edit"
    end
  end

private

  def load_course_lesson_part
    @course_lesson_part = CourseLessonPart.find(params[:id])
    authorize @course_lesson_part
    @course_lesson_part.assign_attributes(course_lesson_part_params)
  end

  def course_lesson_part_params
    params.permit(:content, :title)
  end
end
