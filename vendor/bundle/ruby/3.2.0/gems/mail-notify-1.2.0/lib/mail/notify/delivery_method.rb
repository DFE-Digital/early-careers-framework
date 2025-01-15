# frozen_string_literal: true

module Mail
  module Notify
    class DeliveryMethod
      attr_accessor :settings, :response

      def initialize(settings)
        raise ArgumentError, "You must specify an API key" if settings[:api_key].blank?

        @settings = settings
      end

      def deliver!(mail)
        @mail = mail
        @personalisation = Personalisation.new(mail)
        send_email
      end

      def preview(mail)
        personalisation = Personalisation.new(mail).to_h
        template_id = mail[:template_id].to_s
        client.generate_template_preview(template_id, personalisation: personalisation)
      end

      private

      def client
        @client ||= Notifications::Client.new(@settings[:api_key], @settings[:base_url])
      end

      def email_params
        {
          email_address: @mail.to.first,
          template_id: @mail[:template_id].to_s,
          personalisation: @personalisation.to_h,
          email_reply_to_id: optional_param(:reply_to_id),
          reference: optional_param(:reference)
        }
      end

      def optional_param(name)
        @mail[name].presence&.to_s
      end

      def send_email
        @response = client.send_email(email_params.compact)
      end
    end
  end
end
