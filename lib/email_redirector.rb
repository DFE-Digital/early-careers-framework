# frozen_string_literal: true

module EmailRedirector
  class << self
    def delivering_email(mail)
      return unless enabled?

      overide_personalisation(mail, :subject) { |subject| "#{tags(mail)} #{subject}" }
      mail.to = target_email if enabled?
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

    def overide_personalisation(mail, key, &block)
      value = mail.header["personalisation"].unparsed_value[key]
      return if value.blank?

      mail.header["personalisation"].unparsed_value[key] = block.call(value)
    end

    def add_default_personalisation(mail, key, value)
      mail.header["personalisation"].unparsed_value[key] ||= value
    end

    def tags(mail)
      "[#{app_name} to:#{mail.to.join(',')}] "
    end
  end
end
