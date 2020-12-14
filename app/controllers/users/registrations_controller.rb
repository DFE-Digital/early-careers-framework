class Users::RegistrationsController < ApplicationController
  def start_registration
  end

  def confirm_school
    @school = School.find params["school_id"]
  end

  def check_registration_email
    email = params["induction_coordinator_profile"]["email"]

    @user = User.find_by(email: email)

    if @user
      redirect_to new_user_session_path, notice: "You already have an account. Sign in"
    else
      domain = email.split("@")[1]
      @school = School.find_by(domain: domain)

      if @school && @school.induction_coordinator_profiles.none?
        redirect_to school_confirmation_path(school_id: @school)
      else
        redirect_to check_registration_email_path, alert: "No schools matched your email"
      end
    end
  end
end
