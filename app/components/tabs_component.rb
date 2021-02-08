# frozen_string_literal: true

class TabsComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  renders_many :tabs, "TabComponent"

  class TabComponent < ViewComponent::Base
    attr_reader :path

    def initialize(path:)
      @path = path
    end
  end
end
