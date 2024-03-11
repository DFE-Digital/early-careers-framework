# frozen_string_literal: true

# This module is meant to be registered as an email interceptor on Action Mailer for developers
# debugging and testing purposes.
#
# It adds the :subject_tags personalisation field:
#    For non-production or test emails it adds a personalisation entry like this:
#        subject_tags: "[staging to:aaa@d1.md1,bbb@d2.md2]"
#
#    For production or test environments, the entry added is empty:
#        subject_tags: ""
#
module Mail
  module Personalisation
    class << self
      def delivering_email(mail)
        set_personalisation(mail, :subject_tags, subject_tags(mail))
      end

    private

      def enabled?
        !Rails.env.production? && !Rails.env.test?
      end

      def set_personalisation(mail, key, value)
        mail.header["personalisation"].unparsed_value[key] = value
      end

      def subject_tags(mail)
        enabled? ? "#{tags(mail)} " : Mail::Notify::Personalisation::BLANK
      end

      def tags(mail)
        "[#{Rails.env} to:#{mail.to.join(',')}] "
      end
    end
  end
end
