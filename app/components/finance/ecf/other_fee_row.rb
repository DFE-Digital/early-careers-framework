# frozen_string_literal: true

module Finance
  module ECF
    class OtherFeeRow < BaseComponent
      include ECFPaymentsHelper
      attr_accessor :other_fee, :participants, :per_participant, :subtotal, :breakdown_summary

      def initialize(other_fee:, breakdown_summary:)
        @breakdown_summary = breakdown_summary
        @other_fee = other_fee
        @participants = other_fee[:uplift][:participants]
        @per_participant = other_fee[:uplift][:per_participant]
        @subtotal = other_fee[:uplift][:subtotal]
      end
    end
  end
end
