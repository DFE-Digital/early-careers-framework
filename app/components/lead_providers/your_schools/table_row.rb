# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class TableRow < BaseComponent
      with_collection_parameter :partnership

      def initialize(partnership:, profiles_by_partnership:)
        @partnership = partnership
        @profiles_by_partnership = profiles_by_partnership
      end

    private

      attr_reader :partnership, :profiles_by_partnership

      delegate :school, :cohort, to: :partnership
    end
  end
end
