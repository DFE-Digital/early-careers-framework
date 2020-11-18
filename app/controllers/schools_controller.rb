class SchoolsController < ApplicationController
  def show
    @school = School.find(params[:id])
  end

  def new; end

  def create
    validate_opened_date
    return if performed?

    @school = School.new(params.require(:school).permit(:name, :opened, :school_type))

    if @school&.save
      redirect_to @school
    else
      render "new"
    end
  end

  private
  def validate_opened_date
    unless Date.valid_date?(*opened_date_parts)
      @school = School.new
      @school.errors.add(:opened, 'date validation error text goes here')
      render "new"
    end
  end

  def opened_date_parts

    [
      params.dig(:school, :'opened(1i)').to_i,
      params.dig(:school, :'opened(2i)').to_i,
      params.dig(:school, :'opened(3i)').to_i,
    ]
  end
end
