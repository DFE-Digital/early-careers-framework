# frozen_string_literal: true

module SchoolInformation
  module Details
    class HeadComponent < ViewComponent::Base
      def initialize(school:, selected_cohort:)
        @school = school
        @selected_cohort = selected_cohort
      end
    end
  end
end
