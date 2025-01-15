module GOVUKDesignSystemFormBuilder
  module Elements
    class Hint < Base
      using PrefixableArray

      include Traits::Localisation
      include Traits::HTMLAttributes
      include Traits::HTMLClasses

      def initialize(builder, object_name, attribute_name, value: nil, text: nil, content: nil, radio: false, checkbox: false, **kwargs)
        super(builder, object_name, attribute_name)

        @value           = value
        @radio           = radio
        @checkbox        = checkbox
        @html_attributes = kwargs

        if content
          @raw = capture { content.call }
        else
          @text = retrieve_text(text)
        end
      end

      def active?
        [@text, @raw].any?(&:present?)
      end

      def html
        return unless active?

        tag.div(**attributes(@html_attributes)) { hint_body }
      end

      def hint_id
        return unless active?

        build_id('hint')
      end

    private

      def options
        { class: classes, id: hint_id }
      end

      def hint_body
        @raw || @text
      end

      def retrieve_text(supplied)
        supplied.presence || localised_text(:hint)
      end

      def classes
        %w(hint).prefix(brand).push(radio_class, checkbox_class).compact
      end

      def radio_class
        @radio ? %(#{brand}-radios__hint) : nil
      end

      def checkbox_class
        @checkbox ? %(#{brand}-checkboxes__hint) : nil
      end
    end
  end
end
