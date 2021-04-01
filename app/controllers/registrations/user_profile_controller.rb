# frozen_string_literal: true

class Registrations::UserProfileController < Registrations::SchoolProfileController
  before_action :load_school
  before_action :check_school_available, only: :create

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    ActiveRecord::Base.transaction do
      @user.save!
      @school.induction_coordinator_profiles.destroy_all
      InductionCoordinatorProfile.create!(user: @user, schools: [@school])
    end

    session.delete(:school_id)
    redirect_to :registrations_verification_sent
  rescue ActiveRecord::RecordInvalid
    render :new
  end

private

  def user_params
    params.require(:user).permit(:email, :full_name)
  end

  def load_school
    @school = School.eligible.find_by(urn: session[:school_urn])
    raise ActionController::BadRequest if @school.nil?
  end
end
