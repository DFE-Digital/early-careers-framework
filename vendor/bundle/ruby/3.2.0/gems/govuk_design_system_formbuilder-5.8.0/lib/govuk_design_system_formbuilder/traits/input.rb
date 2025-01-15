module GOVUKDesignSystemFormBuilder
  module Traits
    module Input
      def initialize(builder, object_name, attribute_name, hint:, label:, caption:, prefix_text:, suffix_text:, width:, extra_letter_spacing:, form_group:, **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @width                = width
        @label                = label
        @caption              = caption
        @hint                 = hint
        @prefix_text          = prefix_text
        @suffix_text          = suffix_text
        @html_attributes      = kwargs
        @form_group           = form_group
        @extra_letter_spacing = extra_letter_spacing
      end

      def html
        Containers::FormGroup.new(*bound, **@form_group).html do
          safe_join([label_element, supplemental_content, hint_element, error_element, content])
        end
      end

    private

      def content
        if affixed?
          affixed_input
        else
          input
        end
      end

      def affixed_input
        tag.div(class: %(#{brand}-input__wrapper)) do
          safe_join([prefix, input, suffix])
        end
      end

      def input
        @builder.send(builder_method, @attribute_name, **attributes(@html_attributes))
      end

      def affixed?
        [@prefix_text, @suffix_text].any?
      end

      def options
        {
          id: field_id(link_errors: true),
          class: classes,
          aria: { describedby: combine_references(hint_id, error_id, supplemental_id) }
        }
      end

      def classes
        [%(#{brand}-input)].push(width_classes, error_classes, extra_letter_spacing_classes).compact
      end

      def error_classes
        %(#{brand}-input--error) if has_errors?
      end

      def extra_letter_spacing_classes
        %(#{brand}-input--extra-letter-spacing) if @extra_letter_spacing
      end

      def width_classes
        return if @width.blank?

        case @width

          # fixed (character) widths
        when 20 then %(#{brand}-input--width-20)
        when 10 then %(#{brand}-input--width-10)
        when 5  then %(#{brand}-input--width-5)
        when 4  then %(#{brand}-input--width-4)
        when 3  then %(#{brand}-input--width-3)
        when 2  then %(#{brand}-input--width-2)

          # fluid widths
        when 'full'           then %(#{brand}-!-width-full)
        when 'three-quarters' then %(#{brand}-!-width-three-quarters)
        when 'two-thirds'     then %(#{brand}-!-width-two-thirds)
        when 'one-half'       then %(#{brand}-!-width-one-half)
        when 'one-third'      then %(#{brand}-!-width-one-third)
        when 'one-quarter'    then %(#{brand}-!-width-one-quarter)

        else fail(ArgumentError, "invalid width '#{@width}'")
        end
      end

      def prefix
        return if @prefix_text.blank?

        tag.span(@prefix_text, class: %(#{brand}-input__prefix), **affix_options)
      end

      def suffix
        return if @suffix_text.blank?

        tag.span(@suffix_text, class: %(#{brand}-input__suffix), **affix_options)
      end

      def affix_options
        { aria: { hidden: true } }
      end
    end
  end
end
