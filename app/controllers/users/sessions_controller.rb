# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController  
  def sign_in_with_token
    user = User.find_by(login_token: params[:login_token])

    if user.present?
      user.update(login_token: nil, login_token_valid_until: 1.year.ago)
      sign_in(user)
      redirect_to root_path
    else
      flash[:alert] = 'There was an error while login. Please enter your email again.'
      redirect_to new_user_session_path
    end
  end

  def redirect_from_magic_link
    @login_token = params[:login_token] if params[:login_token].present?
  end
end
