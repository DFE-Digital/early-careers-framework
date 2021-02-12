class Registrations::UserProfileController < ApplicationController
  before_action :load_school
  before_action :check_school_available, only: :create

  def new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.create!(user_params)
      @school.induction_coordinator_profiles.destroy_all
      InductionCoordinatorProfile.create!(user: @user, schools: [@school])
      session.delete(:school_id)
      redirect_to :registrations_verification_sent
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name)
  end

  def load_school
    @school = School.find_by(id: session[:school_id])
    raise ActionController::BadRequest if @school.nil?
  end

  def check_school_available
    if !@school.eligible?
      redirect_to :registrations_school_not_eligible
    elsif @school.fully_registered?
      redirect_to :registrations_school_already_registered
    elsif @school.partially_registered?
      redirect_to :registrations_school_not_confirmed
    end
  end
end
