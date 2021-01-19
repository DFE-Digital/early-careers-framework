# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def info; end

  def start_registration; end

  def new
    @user = User.new
  end

  # def confirm_school
  #   @schools = School.where(id: params["school_ids"])
  #   @email = params["email"]
  # end

  def check_email
    @urn = params["induction_coordinator_profile"]["school_urn"]
    @email = params["induction_coordinator_profile"]["email"]
    @user = User.find_by(email: @email)

    if @user
      flash[:notice] = "This email address already has an account. Sign in."
      redirect_to controller: "/users/sessions", action: :new, email: @email
    else
      @school = School.where(urn: @urn).where("'#{email_domain}' = ANY (domains)").first
      @user = User.new(email: @email)

      if @school
        render :school_not_eligible and return if !@school&.eligible?
        render :confirm_school and return if @school.not_registered?
      else
        flash.now[:alert] = "Your details did not match any schools."
        render :start_registration
      end
    end
  end

  def create
    validate_creation_parameters
    ActiveRecord::Base.transaction do
      super do
        if resource.persisted?
          InductionCoordinatorProfile.create!(user: resource, schools: [@school])
        end
      end
    end
  end

private

  def email_domain
    @email.split("@")[1]
  end

  # def handle_matching_schools
  #   unclaimed_schools = @schools.filter { |school| school.induction_coordinator_profiles.none? }

  #   if unclaimed_schools.any?
      
  #   else
  #     redirect_to root_path, alert: "Someone from your school has already signed up"
  #   end
  # end

  def validate_creation_parameters
    @school = School.find(params[:user][:school_id])
    @email = params[:user][:email]

    raise ActionController::BadRequest if @email.nil?
    raise ActionController::BadRequest unless @school.domains.include?(email_domain)
  rescue ActiveRecord::RecordNotFound
    raise ActionController::BadRequest
  end
end
