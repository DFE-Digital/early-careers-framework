# frozen_string_literal: true

module Mail
  module Redirector
    class << self
      def delivering_email(mail)
        mail.original_to = mail.to
        set_personalisation(mail, :subject_tags, "")#enabled? ? "#{tags(mail)} " : "")

        return unless enabled?

        # TODO: This enforces backward compatibility with existing emails and should be deleted as soon as all the emails
        # are modified to use `subject_tags` instead
        override_personalisation(mail, :subject) { |subject| "#{tags(mail)} #{subject}" }

        mail.to = target_email
      end

      def enabled?
        !Rails.env.production? && !Rails.env.test? && target_email.present?
      end

      def app_name
        if ENV["VCAP_APPLICATION"]
          JSON.parse(ENV["VCAP_APPLICATION"])["application_name"]
        else
          "local"
        end
      end

      def target_email
        ENV["SEND_EMAILS_TO"]
      end

    private

      def override_personalisation(mail, key, &block)
        value = mail.header["personalisation"]&.unparsed_value&.fetch(key, nil)
        return if value.blank?

        set_personalisation(mail, key, block.call(value))
      end

      def tags(mail)
        "[#{app_name} to:#{mail.to.join(',')}] "
      end

      def set_personalisation(mail, key, value)
        mail.header["personalisation"].unparsed_value[key] = value
      end
    end

    module MessageExtension
      attr_accessor :original_to
    end
  end
end
