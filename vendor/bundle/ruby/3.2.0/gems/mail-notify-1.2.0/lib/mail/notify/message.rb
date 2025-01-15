# frozen_string_literal: true

module Mail
  module Notify
    module Message
      def preview
        delivery_method.preview(self) if delivery_method.respond_to?(:preview)
      end
    end
  end
end
