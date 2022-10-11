# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include Pagy::Backend

      def initialize(partnerships:, page:)
        @pagy, @partnerships = paginate(partnerships, page || 1)
      end

    private

      def paginate(data, page)
        if data.is_a? Array
          pagy_array(data, page:, items: 10)
        else
          pagy(data, page:, items: 10)
        end
      end

      attr_reader :partnerships
    end
  end
end
