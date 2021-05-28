# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class TableRow < BaseComponent
      with_collection_parameter :school

      def initialize(school:, cohort:)
        @school = school
        @cohort = cohort
      end

    private

      attr_reader :school, :cohort
    end
  end
end
