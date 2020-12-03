require "devise/strategies/authenticatable"
require_relative "../../../app/mailers/user_mailer"

module Devise
  module Strategies
    class PasswordlessAuthenticatable < Authenticatable
      def authenticate!
        if params[:user].present?
          user = User.find_by(email: params[:user][:email])

          if user&.update(
            login_token: SecureRandom.hex(10),
            login_token_valid_until: 60.minutes.from_now)

            url = Rails.application.routes.url_helpers.email_confirmation_url(
              login_token: user.login_token,
              host: Rails.application.config.domain,
            )

            UserMailer.validate_email(user, url).deliver_now
            fail!("An email was sent to you with a magic link.")
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:passwordless_authenticatable, Devise::Strategies::PasswordlessAuthenticatable)
