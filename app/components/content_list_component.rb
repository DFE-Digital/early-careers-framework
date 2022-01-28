# frozen_string_literal: true

class ContentListComponent < ViewComponent::Base
  def initialize(heading:, list:)
    @heading = heading
    @list = list
  end

  def href_anchor(section_heading)
    "##{section_heading.parameterize}"
  end

  attr_reader :heading, :list
end
