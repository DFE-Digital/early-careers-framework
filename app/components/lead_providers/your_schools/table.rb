# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include PaginationHelper

      def initialize(schools:, cohort:)
        @schools = schools
        @cohort = cohort
      end

    private

      attr_reader :schools, :cohort
    end
  end
end
