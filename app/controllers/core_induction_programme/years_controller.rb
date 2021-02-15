# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized, except: :show
  before_action :authenticate_user!, except: :show
  before_action :load_course_year

  def show; end

  def edit; end

  def update
    if params[:commit] == "Save changes"
      @course_year.save!
      flash[:success] = "Your changes have been saved"
      redirect_to cip_year_url
    else
      render action: "edit"
    end
  end

private

  def load_course_year
    @course_year = CourseYear.find(params[:id])
    authorize @course_year
    @course_year.assign_attributes(course_year_params)
  end

  def course_year_params
    params.permit(:content, :title)
  end
end
