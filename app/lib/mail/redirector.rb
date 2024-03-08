# frozen_string_literal: true

# This module is meant to be registered as an email interceptor on Action Mailer for debugging/testing purposes.
#
# On non production or test environments, it overrides the destination email address of an email to be sent,
# keeping the original one in an attribute (:original_to) added to the Mail::Message class.
#
# The new destination address must be set in ENV["SEND_EMAILS_TO"].
#
module Mail
  module Redirector
    class << self
      def delivering_email(mail)
        if enabled?
          mail.original_to = mail.to
          mail.to = target_email
        end
      end

    private

      def enabled?
        !Rails.env.production? && !Rails.env.test? && target_email.present?
      end

      def target_email
        ENV["SEND_EMAILS_TO"]
      end
    end

    module MessageExtension
      attr_accessor :original_to
    end
  end
end

Mail::Message.include(Mail::Redirector::MessageExtension)
