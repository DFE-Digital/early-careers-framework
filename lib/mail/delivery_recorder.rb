# frozen_string_literal: true

module Mail
  module DeliveryRecorder
    def self.delivered_email(mail)
      return unless Rails.application.config.record_emails

      response = mail.delivery_method.response

      Email.create!(
        id: response.id,
        from: response.content["from_email"],
        to: mail.to,
        template_id: response.template["id"],
        template_version: response.template["version"],
        uri: response.uri,
        personalisation: mail.header["personalisation"].unparsed_value,
      )
    end
  end
end
