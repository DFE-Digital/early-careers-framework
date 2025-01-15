module GOVUKDesignSystemFormBuilder
  module Elements
    class ErrorMessage < Base
      using PrefixableArray

      include Traits::Error

      def html
        return unless has_errors?

        tag.p(class: %(#{brand}-error-message), id: error_id) do
          safe_join([hidden_prefix, message])
        end
      end

    private

      def hidden_prefix
        tag.span('Error: ', class: %(#{brand}-visually-hidden))
      end

      def message
        set_message_safety(@builder.object.errors.messages[@attribute_name]&.first)
      end
    end
  end
end
