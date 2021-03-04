# frozen_string_literal: true

module SchoolInformation
  module Details
    class HeadComponent < BaseComponent
      def initialize(school:, selected_cohort:)
        @school = school
        @selected_cohort = selected_cohort
      end
    end
  end
end
