# frozen_string_literal: true

module SchoolInformation
  module Details
    class MainInfoComponent < ViewComponent::Base
      def initialize(school:)
        @school = school
      end
    end
  end
end
