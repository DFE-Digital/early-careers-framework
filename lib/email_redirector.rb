module EmailRedirector
  class << self
    def delivering_email(mail)
      add_default_personalisation(mail, :_tags, tags(mail))
      mail.to = target_email if enabled?
    end

  private

    def enabled?
      !Rails.env.production? && !Rails.env.test? && target_email.present?
    end

    def tags(mail)
      return "\u200c" unless enabled?
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

    def add_default_personalisation(mail, key, value)
      mail.header['personalisation'].unparsed_value[key] = value
    end
  end
end
