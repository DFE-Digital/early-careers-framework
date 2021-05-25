# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class TableRow < BaseComponent
      include PaginationHelper

      with_collection_parameter :partnership

      def initialize(partnership:)
        @partnership = partnership
      end

    private

      attr_reader :partnership
      delegate :school, :cohort, to: :partnership
    end
  end
end
