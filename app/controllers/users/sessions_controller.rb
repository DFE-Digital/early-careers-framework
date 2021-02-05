# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include ApplicationHelper

  class EmailNotFoundError < StandardError; end
  class LoginIncompleteError < StandardError; end

  TEST_USERS = %w[admin@example.com lead-provider@example.com school-leader@example.com].freeze

  before_action :mock_login, only: :create, if: -> { Rails.env.development? || Rails.env.deployed_development? }

  def create
    super
  rescue LoginIncompleteError
    render :login_email_sent
  rescue EmailNotFoundError
    render :email_not_found
  end

  def sign_in_with_token
    user = User.find_by(login_token: params[:login_token])

    if user.present? && Time.zone.now < user.login_token_valid_until
      user.update!(login_token: nil, login_token_valid_until: 1.year.ago)
      sign_in(user, scope: :user)
      redirect_to helpers.profile_dashboard_url(user)
    else
      flash[:alert] = "There was an error while logging you in. Please enter your email again."
      redirect_to new_user_session_path
    end
  end

  def redirect_from_magic_link
    @login_token = params[:login_token] if params[:login_token].present?
  end

private

  def mock_login
    email = params.dig(:user, :email)
    return unless TEST_USERS.include?(email)

    user = User.find_by_email(email)
    sign_in(user, scope: :user)
    redirect_to profile_dashboard_url(user)
  end
end
