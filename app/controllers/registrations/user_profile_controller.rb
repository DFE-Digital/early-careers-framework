class Registrations::UserProfileController < ApplicationController
  def new
    @user = User.new
    @school = School.find(session[:school_id])
  end

  def create
    
  end

  private

  def user_params
    params.require(:user).permit(:email, :full_name)
  end
end
