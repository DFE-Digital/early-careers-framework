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
# Also, for non production or test environments, emails with a :subject personalisation field are modified to
# prepend the Rails.env and the list of destination emails addresses
# like this:
#       subject: "[development to:aaa@d1.md1,bbb@d2.md2] original_subject_content"
#
module Mail
  module Personalisation
    class << self
      def delivering_email(mail)
        set_personalisation(mail, :subject_tags, subject_tags(mail))

        # TODO: This enforces backward compatibility with existing emails and should be deleted as soon as all the emails
        # are modified to use `subject_tags` instead
        override_personalisation(mail, :subject) { |subject| new_subject(mail, subject) } if enabled?
      end

    private

      def enabled?
        !Rails.env.production? && !Rails.env.test?
      end

      def new_subject(mail, subject)
        "#{tags(mail)} #{subject}"
      end

      def override_personalisation(mail, key, &block)
        value = mail.header["personalisation"]&.unparsed_value&.fetch(key, nil)

        set_personalisation(mail, key, block.call(value)) if value.present?
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
