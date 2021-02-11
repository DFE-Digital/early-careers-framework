class Registrations::SchoolProfileController < ApplicationController
  def show
    @school_profile_form = SchoolProfileForm.new
  end

  def create
    @school_profile_form = SchoolProfileForm.new(school_params)

    if @school_profile_form.valid?
      @school = School.find_by(urn: school_params[:urn])
      session["school_id"] = @school.id
      redirect_to :new_registrations_user_profile
    else
      render :show
    end
  end

  private

  def school_params
    params.require(:school).permit(:urn)
  end
end
