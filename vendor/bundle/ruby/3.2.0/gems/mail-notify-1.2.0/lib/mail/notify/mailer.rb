# frozen_string_literal: true

module Mail
  module Notify
    class Mailer < ActionMailer::Base
      def view_mail(template_id, headers)
        raise ArgumentError, "You must specify a template ID" if template_id.blank?

        mail(headers.merge(template_id: template_id))
      end

      def template_mail(template_id, headers)
        raise ArgumentError, "You must specify a template ID" if template_id.blank?

        mail(headers.merge(body: "", subject: "", template_id: template_id))
      end

      def blank_allowed(value)
        value.presence || Personalisation::BLANK
      end
    end
  end
end
