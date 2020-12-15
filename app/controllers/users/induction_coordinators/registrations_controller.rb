# frozen_string_literal: true

class Users::InductionCoordinators::RegistrationsController < Devise::RegistrationsController
  def start_registration; end

  def confirm_school
    @schools = School.where(id: params["school_ids"])
    @email = params["email"]
  end

  def check_registration_email
    @email = params["induction_coordinator_profile"]["email"]

    @user = User.find_by(email: @email)

    if @user
      flash[:notice] = "You already have an account. Sign in"
      redirect_to controller: "/users/sessions", action: :new, email: @email
    else
      domain = @email.split("@")[1]
      @schools = School.where("'#{domain}' = ANY (domains)")

      if @schools.any?
        handle_matching_schools
      else
        redirect_to induction_coordinator_registration_check_email_path, alert: "No schools matched your email"
      end
    end
  end

  def handle_matching_schools
    unclaimed_schools = @schools.filter { |school| school.induction_coordinator_profiles.none? }

    if unclaimed_schools.one?
      redirect_to controller: "users/induction_coordinators/registrations", action: :confirm_school, school_ids: unclaimed_schools.first, email: @email
    elsif unclaimed_schools.any?
      redirect_to controller: "users/induction_coordinators/registrations", action: :confirm_school, school_ids: unclaimed_schools, email: @email
    else
      redirect_to root_path, alert: "Someone from your school has already signed up"
    end
  end

  def new
    @email = params[:email]
    @school = School.find(params[:school_id])
    super do
      render "users/induction_coordinators/registrations/new" and return
    end
  end

  def create
    school = School.find(params[:user][:school_id])
    super do
      if resource.persisted?
        profile = InductionCoordinatorProfile.create!(user: resource, schools: [school])
      end
    rescue StandardError => e
      profile&.destroy!
      resource&.destroy!
      raise e
    end
  end
end
