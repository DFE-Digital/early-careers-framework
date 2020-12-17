# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    @email = params[:email]
    super
  end

  def sign_in_with_token
    user = User.find_by(login_token: params[:login_token])

    if user.present? && Time.zone.now < user.login_token_valid_until
      user.update!(login_token: nil, login_token_valid_until: 1.year.ago)
      sign_in(user, scope: :user)
      redirect_to dashboard_path
    else
      flash[:alert] = "There was an error while logging you in. Please enter your email again."
      redirect_to new_user_session_path
    end
  end

  def redirect_from_magic_link
    @login_token = params[:login_token] if params[:login_token].present?
  end
end
