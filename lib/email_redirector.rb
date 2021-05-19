module EmailRedirector
  class << self
    def delivering_email(mail)
      mail.header['personalisation'].unparsed_value[:_prefixes] = prefixes(mail)
      mail.to = target_email if enabled?
    end

  private

    def enabled?
      return false
      !Rails.env.production? && !Rails.env.test? && target_email.present?
    end

    def prefixes(mail)
      return "" unless enabled?

      "[#{app_name} to:#{mail.to.join(',')}] "
    end

    def app_name
      if ENV["VCAP_APPLICATION"]
        JSON.parse(ENV["VCAP_APPLICATION"])["application_name"]
      else
        "local"
      end
    end

    def target_email
      ENV['SEND_EMAILS_TO']
    end
  end
end
