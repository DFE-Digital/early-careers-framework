# frozen_string_literal: true

class AutoTagComponent < ViewComponent::Base
  def initialize(text:)
    colours = {
      "to do": "grey",
      "cannot start yet": "grey",
      "setup complete": "green",
      "done": "green",
    }

    @text = text
    @colour = colours[text.downcase.to_sym] || "grey"
  end

  def call
    render GovukComponent::Tag.new(text: @text, colour: @colour)
  end
end
