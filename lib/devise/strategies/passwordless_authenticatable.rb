# frozen_string_literal: true

require "devise/strategies/authenticatable"
require_relative "../../../app/mailers/user_mailer"

module Devise
  module Strategies
    class PasswordlessAuthenticatable < Authenticatable
      class Error < StandardError; end

      class EmailNotFoundError < Error; end

      class LoginIncompleteError < Error; end

      def authenticate!
        if params[:user].present?
          user = User.find_by(email: params[:user][:email])

          token_expiry = 60.minutes.from_now
          result = user&.update(
            login_token: SecureRandom.hex(10),
            login_token_valid_until: token_expiry,
          )

          if result
            url = Rails.application.routes.url_helpers.users_confirm_sign_in_url(
              login_token: user.login_token,
              host: Rails.application.config.domain,
            )

            UserMailer.sign_in_email(user: user, url: url, token_expiry: token_expiry.to_s(:time)).deliver_now
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
