# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include Pagy::Backend

      def initialize(partnerships:, participant_counts:, page:)
        @pagy, @partnerships = paginate(partnerships, page || 1)
        @participant_counts = participant_counts
      end

    private

      def paginate(data, page)
        if data.is_a? Array
          pagy_array(data, page:, items: 10)
        else
          pagy(data, page:, items: 10)
        end
      end

      attr_reader :partnerships, :participant_counts
    end
  end
end
