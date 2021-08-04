# frozen_string_literal: true

module Finance
  module ECF
    class ServiceFeeRow < BaseComponent
      include FinanceHelper
      attr_reader :band, :participants, :per_participant, :monthly
      with_collection_parameter :service_fee

    private

      def initialize(service_fee:)
        @band = service_fee[:band]
        @participants = service_fee[:participants]
        @per_participant = service_fee[:per_participant]
        @monthly = service_fee[:monthly]
      end
    end
  end
end
