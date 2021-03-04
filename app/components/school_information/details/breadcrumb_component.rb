# frozen_string_literal: true

module SchoolInformation
  module Details
    class BreadcrumbComponent < BaseComponent
      def initialize(selected_cohort:)
        @selected_cohort = selected_cohort
      end
    end
  end
end
