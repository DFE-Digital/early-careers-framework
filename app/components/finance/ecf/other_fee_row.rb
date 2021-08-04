# frozen_string_literal: true

module Finance
  module ECF
    class OtherFeeRow < BaseComponent
      include FinanceHelper
      attr_reader :other_fee
      with_collection_parameter :other_fee
      delegate :participants, :name, :per_participant, :subtotal, to: :other_fee

      private

      def initialize(other_fee:)
        @other_fee=other_fee
      end
    end
  end
end
