# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include PaginationHelper

      def initialize(schools:, cohort:, page:)
        @schools = schools.page(page).per(20)
        @cohort = cohort
      end

    private

      attr_reader :schools, :cohort
    end
  end
end
