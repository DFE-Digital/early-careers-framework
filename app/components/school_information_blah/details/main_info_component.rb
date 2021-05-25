# frozen_string_literal: true

module SchoolInformation
  module Details
    class MainInfoComponent < BaseComponent
      def initialize(school:)
        @school = school
      end
    end
  end
end
