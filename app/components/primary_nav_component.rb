# frozen_string_literal: true

class PrimaryNavComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_many :nav_items, "NavItemComponent"

  class NavItemComponent < ViewComponent::Base
    attr_reader :path

    def initialize(path:)
      @path = path
    end

    def current_section?(path)
      request.path.include?(path)
    end
  end
end
