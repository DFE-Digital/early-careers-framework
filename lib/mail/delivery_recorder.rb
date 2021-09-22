# frozen_string_literal: true

module Mail
  module DeliveryRecorder
    def self.delivered_email(mail)
      return unless Rails.application.config.record_emails

      response = mail.delivery_method.response

      ApplicationRecord.transaction do
        email = Email.create!(
          id: response.id,
          from: response.content["from_email"],
          to: mail.original_to,
          template_id: response.template["id"],
          template_version: response.template["version"],
          uri: response.uri,
          personalisation: mail.header["personalisation"].unparsed_value,
        )

        email.associate_with(*User.where(email: email.to).to_a)

        mail.associations.each do |object, name|
          email.associate_with object, as: name
        end
      end
    end

    def self.enable!
      Mail::Message.include(MessageExtension)
      ActionMailer::Base.register_observer(self)
    end

    module MessageExtension
      def associations
        @associations ||= []
      end

      def associate_with(object, as: nil)
        associations << [object, as]
        self
      end
    end
  end
end
