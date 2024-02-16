# frozen_string_literal: true

module Admin
  module Performance
    class ValidationErrorComponent < BaseComponent
      attr_reader :error

      def initialize(error:)
        @error = error
      end

      def header_label
        "#{validation_error_label}#{created_at_label}#{user_label}"
      end

    private

      def validation_error_label
        "Validation error ##{error.id.slice(0, 8)} – "
      end

      def created_at_label
        error.created_at.strftime("%d %B %Y at %H:%M")
      end

      def user_label
        if error.user
          " by user #{error.user.full_name}"
        end
      end
    end
  end
end
