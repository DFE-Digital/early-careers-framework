# frozen_string_literal: true

class TabsComponent < BaseComponent
  include ViewComponent::SlotableV2

  renders_many :tabs, "TabComponent"

  class TabComponent < BaseComponent
    attr_reader :path

    def initialize(path:)
      @path = path
    end
  end
end
