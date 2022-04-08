# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include PaginationHelper
      include Pagy::Backend

      def initialize(partnerships:, page:)
        @pagy, @partnerships = pagy(partnerships, page: page || 1, items: 10)
      end

    private

      attr_reader :partnerships
    end
  end
end
