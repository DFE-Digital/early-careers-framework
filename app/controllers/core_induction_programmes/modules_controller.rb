# frozen_string_literal: true

class CoreInductionProgrammes::ModulesController < ApplicationController
  include Pundit
  include GovspeakHelper
  include CipBreadcrumbHelper

  after_action :verify_authorized
  before_action :authenticate_user!, except: :show
  before_action :load_course_module, only: %i[update edit show]
  before_action :make_course_module, only: %i[new create]

  def show
    @course_lessons_with_progress = @course_module.lessons_with_progress current_user
  end

  def new; end

  def create
    next_module = find_next_module
    @course_module.assign_attributes(course_module_params)

    if @course_module.valid?
      @course_module.save!
      next_module&.update!(previous_module: @course_module)
      redirect_to cip_index_path
    else
      render action: "new"
    end
  end

  def edit; end

  def update
    next_module = @course_module.next_module
    previous_module = @course_module.previous_module
    @course_module.assign_attributes(course_module_params)

    if params[:commit] == "Save changes"
      @course_module.save!
      next_module&.update!(previous_module: previous_module)

      flash[:success] = "Your changes have been saved"
      redirect_to year_module_url
    else
      render action: "edit"
    end
  end

private

  def make_course_module
    authorize CourseModule
    core_induction_programme = CoreInductionProgramme.find(params[:cip_id])
    @course_years = core_induction_programme.course_years
    @course_modules = CourseModule.where(course_year_id: @course_years.map(&:id))
    @course_module = CourseModule.new
  end

  def load_course_module
    @course_module = CourseModule.find(params[:id])
    @course_years = @course_module.course_year.core_induction_programme&.course_years || []
    @course_modules = @course_module.other_modules_in_year
    authorize @course_module
  end

  def course_module_params
    params
        .require(:course_module)
        .permit(:content, :title, :term, :course_year_id, :previous_module_id)
  end

  def find_next_module
    previous_module_id = params[:course_module][:previous_module_id]
    previous_module = CourseModule.where(id: previous_module_id).first
    previous_module&.next_module
  end
end
