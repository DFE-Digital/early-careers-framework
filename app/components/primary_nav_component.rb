# frozen_string_literal: true

class PrimaryNavComponent < ViewComponent::Base
  attr_reader :wide, :reversed

  renders_many :nav_items, "NavItemComponent"

  def initialize(wide: false, reversed: false)
    @wide = wide
    @reversed = reversed
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
