# frozen_string_literal: true

module Mail
  module Notify
    class Personalisation
      def to_h
        {
          body: @body,
          subject: @subject,
        }.reject { |_, value| value.blank? }.merge(@personalisation)
      end
    end
  end
end
