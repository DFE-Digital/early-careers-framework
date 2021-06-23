# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include PaginationHelper

      def initialize(partnerships:, page:)
        @partnerships = partnerships.page(page).per(10)
      end

    private

      attr_reader :partnerships
    end
  end
end
