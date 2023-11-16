# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class TableRow < BaseComponent
      with_collection_parameter :partnership

      def initialize(partnership:, participant_counts:)
        @partnership = partnership
        @participant_counts = participant_counts
      end

    private

      attr_reader :partnership, :participant_counts

      delegate :school, :cohort, to: :partnership
    end
  end
end
