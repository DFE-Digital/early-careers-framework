# frozen_string_literal: true

module Finance
  module ECF
    class OutputPaymentRow < BaseComponent
      include FinanceHelper
      attr_reader :band, :participants, :per_participant, :subtotal
      with_collection_parameter :output_payment

    private

      def initialize(output_payment:)
        @band = output_payment[:band]
        @participants = output_payment[:participants]
        @per_participant = output_payment[:per_participant]
        @subtotal = output_payment[:subtotal]
      end
    end
  end
end
