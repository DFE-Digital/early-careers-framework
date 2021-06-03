# frozen_string_literal: true

class AutoTagComponent < ViewComponent::Base
  COLOURS = {
    "to do": "yellow",
    "cannot start yet": "grey",
    "setup complete": "green",
    "done": "green",
  }.freeze

  def initialize(text:)
    @text = text
    @colour = COLOURS[text.downcase.to_sym] || "grey"
  end

  def call
    return "" if @text.blank?
    render GovukComponent::Tag.new(text: @text, colour: @colour)
  end
end
