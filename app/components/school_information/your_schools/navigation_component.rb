# frozen_string_literal: true

module SchoolInformation
  module YourSchools
    class NavigationComponent < ViewComponent::Base
      def initialize(cohorts:, selected_cohort:)
        @cohorts = cohorts
        @selected_cohort = selected_cohort
      end
    end
  end
end
