# frozen_string_literal: true

class Registrations::SchoolProfileController < ApplicationController
  def show
    @school_profile_form = SchoolProfileForm.new
  end

  def create
    @school_profile_form = SchoolProfileForm.new(school_params)

    if @school_profile_form.valid?
      load_school
      redirect
    else
      render :show
    end
  end

private

  def school_params
    params.require(:school_profile_form).permit(:urn)
  end

  def load_school
    session["school_urn"] = school_params[:urn]
    @school = School.eligible.find_by(urn: school_params[:urn])
  end

  def redirect
    if !@school.eligible?
      redirect_to :registrations_school_not_eligible
    elsif @school.fully_registered?
      redirect_to :registrations_school_registered
    elsif @school.partially_registered?
      redirect_to :registrations_school_not_confirmed
    elsif controller_name == "school_profile"
      redirect_to :new_registrations_user_profile
    end
  end

  alias_method :check_school_available, :redirect
end
