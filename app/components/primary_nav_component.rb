# frozen_string_literal: true

class PrimaryNavComponent < ViewComponent::Base
  include ViewComponent::SlotableV2
  attr_reader :wide

  renders_many :nav_items, "NavItemComponent"

  def initialize(wide: false)
    @wide = wide
  end

  class NavItemComponent < ViewComponent::Base
    attr_reader :path

    def initialize(path:, selected: false)
      @path = path
      @selected = selected
    end

    def current_section?(path)
      @selected || request.path.include?(path)
    end
  end
end
