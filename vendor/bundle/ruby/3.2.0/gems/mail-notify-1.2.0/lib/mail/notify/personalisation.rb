# frozen_string_literal: true

module Mail
  module Notify
    class Personalisation
      BLANK = Object.new

      def initialize(mail)
        @body = mail.body.raw_source
        @subject = mail.subject
        @personalisation = mail[:personalisation]&.unparsed_value || {}
      end

      def to_h
        merged_options
          .reject { |_k, v| v.blank? }
          .transform_values { |value| (value == BLANK) ? "" : value }
      end

      private

      def merged_options
        {
          body: @body,
          subject: @subject
        }.merge(@personalisation)
      end
    end
  end
end
