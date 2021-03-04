# frozen_string_literal: true

class BaseComponent < ViewComponent::Base
  def component_form_with(**options, &block)
    form_with(**options.merge(builder: GOVUKDesignSystemFormBuilder::FormBuilder), &block)
  end
end
