# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include PaginationHelper

      def initialize(partnerships:)
        @partnerships = partnerships
      end

    private

      attr_reader :partnerships
    end
  end
end
