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

    def initialize(path:, selected: nil)
      @path = path
      @selected = selected
    end

    def current_section?(path)
      return request.path.include?(path) if @selected.nil?
      @selected
    end
  end
end
