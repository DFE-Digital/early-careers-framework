# frozen_string_literal: true

class CoreInductionProgramme::YearsController < ApplicationController
  include Pundit
  include GovspeakHelper

  after_action :verify_authorized, except: :show
  before_action :authenticate_user!, except: :show
  before_action :load_and_authorize_course_year

  def show; end

  def edit
    @year_preview = params[:year_preview] || @course_year.content
    @html_content = content_to_html(@year_preview)
  end

  def update
    if params[:commit] == "Save changes"
      @course_year.update!(content: params[:year_preview])
      flash[:success] = "Your changes have been saved"
      redirect_to cip_year_url
    else
      @year_preview = params[:year_preview]
      @html_content = content_to_html(@year_preview)
      render action: "edit"
    end
  end

private

  def load_and_authorize_course_year
    @course_year = CourseYear.find(params[:id])
    authorize @course_year
  end
end
