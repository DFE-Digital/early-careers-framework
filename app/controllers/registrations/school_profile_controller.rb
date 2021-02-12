class Registrations::SchoolProfileController < ApplicationController
  def show
    @school_profile_form = SchoolProfileForm.new
  end

  def create
    @school_profile_form = SchoolProfileForm.new(school_params)

    if @school_profile_form.valid?
      load_school
      check_school_available  
    else
      render :show
    end
  end

  private

  def school_params
    params.require(:school).permit(:urn)
  end

  def load_school
    @school = School.find_by(urn: school_params[:urn])
    session["school_id"] = @school.id
  end

  def check_school_available
    if !@school.eligible?
      redirect_to :registrations_school_not_eligible
    elsif @school.fully_registered?
      redirect_to :registrations_school_already_registered
    elsif @school.partially_registered?
      redirect_to :registrations_school_not_confirmed
    else
      redirect_to :new_registrations_user_profile
    end
  end
end
