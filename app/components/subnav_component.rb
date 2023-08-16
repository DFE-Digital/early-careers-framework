# frozen_string_literal: true

class SubnavComponent < BaseComponent
  renders_many :nav_items, "NavItemComponent"

  class NavItemComponent < BaseComponent
    attr_reader :path

    def initialize(path:)
      @path = path
    end
  end
end
