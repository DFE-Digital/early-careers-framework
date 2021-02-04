# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  class EmailNotFoundError < StandardError; end
  class LoginIncompleteError < StandardError; end

  before_action :redirect_to_dashboard, only: %i[sign_in_with_token redirect_from_magic_link]
  before_action :ensure_login_token_valid, only: %i[sign_in_with_token redirect_from_magic_link]

  def create
    super
  rescue LoginIncompleteError
    render :login_email_sent
  rescue EmailNotFoundError
    render :email_not_found
  end

  def sign_in_with_token
    @user.update!(login_token: nil, login_token_valid_until: 1.year.ago)
    sign_in(@user, scope: :user)
    redirect_to_dashboard
  end

  def redirect_from_magic_link
    @login_token = params[:login_token] if params[:login_token].present?
  end

private

  def redirect_to_dashboard
    redirect_to helpers.profile_dashboard_url(current_user) if current_user.present?
  end

  def ensure_login_token_valid
    @user = User.find_by(login_token: params[:login_token])
    unless @user.present? && Time.zone.now < @user.login_token_valid_until
      flash[:alert] = "There was an error while logging you in. Please enter your email again."
      redirect_to new_user_session_path
    end
  end
end
