# frozen_string_literal: true

module LeadProviders
  module YourSchools
    class Table < BaseComponent
      include Pagy::Backend

      def initialize(partnerships:, profiles_by_partnership:, page:)
        @pagy, @partnerships = paginate(partnerships, page || 1)
        @profiles_by_partnership = profiles_by_partnership
      end

    private

      def paginate(data, page)
        if data.is_a? Array
          pagy_array(data, page:, items: 10)
        else
          pagy(data, page:, items: 10)
        end
      end

      attr_reader :partnerships, :profiles_by_partnership
    end
  end
end
