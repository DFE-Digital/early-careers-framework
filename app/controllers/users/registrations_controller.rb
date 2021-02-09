# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def info; end

  def new
    @user = User.new
  end

  def check_details
    @urn = params["induction_coordinator_profile"]["school_urn"]
    @email = params["induction_coordinator_profile"]["email"]
    @user = User.find_or_initialize_by(email: @email)
    @school = School.where(urn: @urn).where("'#{email_domain}' = ANY (domains)").first

    render :user_already_registered and return if @user.persisted?
    render_start_registration and return if @school.nil?
    render :school_not_eligible and return unless @school.eligible?
    render :school_fully_registered and return if @school.fully_registered?
    render :school_partially_registered and return if @school.partially_registered?

    render :school_not_registered
  end

  def create
    validate_creation_parameters
    build_resource(sign_up_params)

    ActiveRecord::Base.transaction do
      resource.save!
      @school.induction_coordinator_profiles.destroy_all
      InductionCoordinatorProfile.create!(user: resource, schools: [@school])
      expire_data_after_sign_in!
      render :verification_email_sent
    end
  end

private

  def email_domain
    @email.split("@")[1]
  end

  def render_start_registration
    flash.now[:alert] = "Your details did not match any schools."
    render :start_registration
  end

  def validate_creation_parameters
    @school = School.find_by(id: params[:user][:school_id])
    @email = params[:user][:email]

    raise ActionController::BadRequest if @email.blank?
    raise ActionController::BadRequest if @school.blank?
    raise ActionController::BadRequest unless @school.domains.include?(email_domain)
    raise ActionController::BadRequest if @school.fully_registered?
    raise ActionController::BadRequest if @school.partially_registered?
  end
end
