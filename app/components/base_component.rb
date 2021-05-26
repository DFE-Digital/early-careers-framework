# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  def self.translation_key
    @translation_key ||= name.snakecase.gsub("/", ".")
  end

  def component_form_with(**options, &block)
    form_with(**options.merge(builder: GOVUKDesignSystemFormBuilder::FormBuilder), &block)
  end

  def t(key, **options)
    return super unless key.start_with?(".")

    super(self.class.translation_key + key, **options)
  end
end
