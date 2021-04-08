# frozen_string_literal: true

class CoreInductionProgrammes::YearsController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized
  before_action :authenticate_user!
  before_action :load_course_year, except: %i[new create]

  def new
    authorize CourseYear
    @core_induction_programmes = CoreInductionProgramme.all
    @course_year = CourseYear.new
  end

  def create
    authorize CourseYear
    @course_year = CourseYear.new(course_year_params)

    if @course_year.valid?
      @course_year.save!
      redirect_to cip_index_path
    else
      @core_induction_programmes = CoreInductionProgramme.all
      render action: "new"
    end
  end

  def edit; end

  def update
    if params[:commit] == "Save changes"
      @course_year.save!
      flash[:success] = "Your changes have been saved"
      redirect_to cip_path(@course_year.core_induction_programme)
    else
      render action: "edit"
    end
  end

private

  def load_course_year
    @course_year = CourseYear.find(params[:id])
    authorize @course_year
    @course_year.assign_attributes(course_year_params)
    @course_modules_with_progress = @course_year.modules_with_progress current_user
  end

  def course_year_params
    return {} unless params.key? :course_year

    params.require(:course_year).permit(:title, :content)
  end
end
