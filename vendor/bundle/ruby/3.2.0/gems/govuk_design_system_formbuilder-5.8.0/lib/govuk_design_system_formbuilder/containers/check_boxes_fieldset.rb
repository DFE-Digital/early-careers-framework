module GOVUKDesignSystemFormBuilder
  module Containers
    class CheckBoxesFieldset < Base
      include Traits::Error
      include Traits::Hint

      def initialize(builder, object_name, attribute_name, hint:, legend:, caption:, small:, form_group:, multiple:, **kwargs, &block)
        fail LocalJumpError, 'no block given' unless block_given?

        super(builder, object_name, attribute_name, &block)

        @legend          = legend
        @caption         = caption
        @hint            = hint
        @small           = small
        @form_group      = form_group
        @multiple        = multiple
        @html_attributes = kwargs
      end

      def html
        Containers::FormGroup.new(*bound, **@form_group).html do
          Containers::Fieldset.new(*bound, **fieldset_options).html do
            safe_join([hint_element, error_element, hidden_field, checkboxes])
          end
        end
      end

    private

      def hidden_field
        return unless @multiple

        @builder.hidden_field(@attribute_name, value: "", name: hidden_field_name)
      end

      def hidden_field_name
        format("%<object_name>s[%<attribute_name>s][]", object_name: @object_name, attribute_name: @attribute_name)
      end

      def fieldset_options
        {
          legend: @legend,
          caption: @caption,
          described_by: [error_element.error_id, hint_element.hint_id]
        }
      end

      def checkboxes
        Containers::CheckBoxes.new(@builder, small: @small, **@html_attributes).html do
          @block_content
        end
      end
    end
  end
end
