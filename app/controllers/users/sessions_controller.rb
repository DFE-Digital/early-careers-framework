# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  class EmailNotFoundError < StandardError; end
  class LoginIncompleteError < StandardError; end

  TEST_USERS = %w[
    admin@example.com
    ambition-institute-early-career-teacher@example.com
    education-development-trust-early-career-teacher@example.com
    teach-first-early-career-teacher@example.com
    ucl-early-career-teacher@example.com
    mentor@example.com
  ].freeze

  before_action :mock_login, only: :create, unless: -> { Rails.env.production? }
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
    redirect_to dashboard_url if current_user.present?
  end

  def ensure_login_token_valid
    @user = User.find_by(login_token: params[:login_token])

    if @user.blank? || login_token_expired?
      flash[:alert] = "There was an error while logging you in. Please enter your email again."
      redirect_to new_user_session_path
    end
  end

  def login_token_expired?
    Time.zone.now > @user.login_token_valid_until
  end

  def mock_login
    email = params.dig(:user, :email)
    return unless TEST_USERS.include?(email)

    user = User.find_by_email(email)
    sign_in(user, scope: :user)
    redirect_to dashboard_url
  end
end
