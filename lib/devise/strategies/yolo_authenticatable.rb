# frozen_string_literal: true

require "devise/strategies/authenticatable"

module Devise
  module Strategies
    class YoloAuthenticatable < Authenticatable
      def authenticate!
        if params[:user].present?
          user = User.find_by(email: params[:user][:email])

          if user.present?
            success! user
          else
            errors.add :email, "Enter the email address your school used when they created your account"
            fail! "This email address is not the same as the one your school used to create your account."
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:yolo_authenticatable, Devise::Strategies::YoloAuthenticatable)
