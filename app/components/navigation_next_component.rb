# frozen_string_literal: true

class NavigationNextComponent < ViewComponent::Base
  def initialize(url:, text:)
    @url = url
    @text = text
  end
end
