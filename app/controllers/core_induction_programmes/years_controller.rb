# frozen_string_literal: true

class CoreInductionProgrammes::YearsController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized
  before_action :authenticate_user!
  before_action :load_course_year

  def edit; end

  def update
    if params[:commit] == "Save changes"
      @course_year.save!
      flash[:success] = "Your changes have been saved"
      redirect_to cip_url(@course_year.core_induction_programme)
    else
      render action: "edit"
    end
  end

private

  def load_course_year
    @course_year = CourseYear.find(params[:id])
    authorize @course_year
    @course_year.assign_attributes(course_year_params)
    @course_modules_with_progress = @course_year.modules_with_progress @current_user
  end

  def course_year_params
    params.permit(:content, :title)
  end
end
