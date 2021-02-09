# frozen_string_literal: true

class CoreInductionProgramme::ModulesController < ApplicationController
  include Pundit
  include GovspeakHelper

  after_action :verify_authorized, except: :show
  before_action :authenticate_user!, except: :show
  before_action :load_and_authorize_course_module

  def show; end

  def edit
    @module_preview = params[:module_preview] || @course_module.content
    @html_content = content_to_html(@module_preview)
  end

  def update
    if params[:commit] == "Save changes"
      @course_module.update!(content: params[:module_preview])
      flash[:success] = "Your changes have been saved"
      redirect_to cip_year_module_url
    else
      @module_preview = params[:module_preview]
      @html_content = content_to_html(@module_preview)
      render action: "edit"
    end
  end

private

  def load_and_authorize_course_module
    @course_module = CourseModule.find(params[:id])
    authorize @course_module
  end
end
