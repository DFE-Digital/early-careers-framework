# frozen_string_literal: true

require "devise/strategies/authenticatable"
require_relative "../../../app/mailers/user_mailer"

module Devise
  module Strategies
    class PasswordlessAuthenticatable < Authenticatable
      class Error < StandardError; end

      class EmailNotFoundError < Error; end

      class LoginIncompleteError < Error; end

      def valid?
        NotifyEmailValidator.valid?(params.dig(:user, :email))
      end

      def authenticate!
        if params[:user].present?
          email = params.dig(:user, :email)

          user = Identity.find_user_by(email:)

          token_expiry = 12.hours.from_now
          result = user&.update(
            login_token: SecureRandom.hex(10),
            login_token_valid_until: token_expiry,
          )

          if result
            url = Rails.application.routes.url_helpers.users_confirm_sign_in_url(
              login_token: user.login_token,
              host: Rails.application.config.domain,
              **UTMService.email(:sign_in),
            )

            UserMailer.with(email: email.downcase, full_name: user.full_name, url:, token_expiry: token_expiry.localtime.to_s(:time)).sign_in_email.deliver_later(queue: "priority_mailers")
            raise LoginIncompleteError
          else
            raise EmailNotFoundError
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:passwordless_authenticatable, Devise::Strategies::PasswordlessAuthenticatable)
