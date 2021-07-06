# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include ApplicationHelper

  TEST_DOMAINS = %w[
    example.com
    ambition.org.uk
    churchofengland.org
    pracedo.com
    ucl.ac.uk
    tribalgroup.com
    teachfirst.org.uk
    educationdevelopmenttrust.com
    capita.com
    bestpracticenet.co.uk
    aircury.com
    setsquaresolutions.com
    harrisfederation.org.uk
    harrischaffordhundred.org.uk
    llse.org.uk
    realgroup.co.uk
    teacherdevelopmenttrust.org 
    uclconsultants.com
  ].freeze

  skip_before_action :check_privacy_policy_accepted
  before_action :mock_login, only: :create, if: -> { Rails.env.development? || Rails.env.deployed_development? || Rails.env.sandbox? }
  before_action :redirect_to_dashboard, only: %i[sign_in_with_token redirect_from_magic_link]
  before_action :ensure_login_token_valid, only: %i[sign_in_with_token redirect_from_magic_link]

  def new
    super do
      if flash.present?
        flash.clear
        resource.valid?
        resource.errors.delete(:full_name)
      end
    end
  end

  def create
    super
  rescue Devise::Strategies::PasswordlessAuthenticatable::Error
    render :login_email_sent
  end

  def sign_in_with_token
    @user.update!(login_token: nil, login_token_valid_until: 1.year.ago)
    sign_in(@user, scope: :user)
    redirect_to_dashboard
  end

  def redirect_from_magic_link
    @login_token = params[:login_token] if params[:login_token].present?
  end

  def signed_out; end

  def link_invalid; end

private

  def redirect_to_dashboard
    redirect_to helpers.profile_dashboard_path(current_user) if current_user.present?
  end

  def ensure_login_token_valid
    @user = User.find_by(login_token: params[:login_token])

    if @user.blank? || login_token_expired?
      redirect_to users_link_invalid_path
    end
  end

  def login_token_expired?
    Time.zone.now > @user.login_token_valid_until
  end

  def mock_login
    email = params.dig(:user, :email)
    return unless TEST_DOMAINS.any? { |domain| email.include?(domain) }

    user = User.find_by_email(email)
    sign_in(user, scope: :user)
    redirect_to profile_dashboard_path(user)
  end
end
