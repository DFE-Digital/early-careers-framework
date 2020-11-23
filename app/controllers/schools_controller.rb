require 'byebug'

class SchoolsController < ApplicationController
  rescue_from ActiveRecord::MultiparameterAssignmentErrors,
              with: :invalid_date_handler 

  def show
    @school = School.find(params[:id])
  end

  def new
    @school = School.new
  end

  def create
    @school = School.new(school_parameters)

    if @school.save
      redirect_to @school
    else
      render :new
    end
  end

private

  def school_parameters
    params.require(:school).permit(:name, :opened_at, :school_type)
  end

  def invalid_date_handler
    @school = School.new
    @school.errors.add(:opened_at, "Date is invalid")
    render :new
  end
end
