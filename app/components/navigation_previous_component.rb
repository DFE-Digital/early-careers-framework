# frozen_string_literal: true

class NavigationPreviousComponent < ViewComponent::Base
  def initialize(url:, text:)
    @url = url
    @text = text
  end
end
