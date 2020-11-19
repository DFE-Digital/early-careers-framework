class SchoolsController < ApplicationController
  def show
    @school = School.find(params[:id])
  end

  def new; end

  def create
    validate_opened_date
    return if performed?

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

  def validate_opened_date
    unless Date.valid_date?(*opened_date_parts)
      @school = School.new(params.require(:school).permit(:name, :school_type))
      @school.errors.add(:opened_at, "date validation error text goes here")
      render :new
    end
  end

  def opened_date_parts

    [
      params.dig(:school, :"opened_at(1i)").to_i,
      params.dig(:school, :"opened_at(2i)").to_i,
      params.dig(:school, :"opened_at(3i)").to_i,
    ]
  end
end
