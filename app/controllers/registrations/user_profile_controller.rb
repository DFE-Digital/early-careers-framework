# frozen_string_literal: true

class Registrations::UserProfileController < Registrations::SchoolProfileController
  before_action :load_school
  before_action :check_school_available, only: :create

  def new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.find_or_create_by!(email: user_params[:email]) do |user|
        user.full_name = user_params[:full_name]
      end
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
    @school = School.find_by(urn: session[:school_urn])
    raise ActionController::BadRequest if @school.nil?
  end
end
