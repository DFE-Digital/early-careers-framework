# frozen_string_literal: true

describe ::PaymentCalculator::Npq::PaymentCalculation do
  let(:config) do
    {
      recruitment_target: 2000,
      per_participant_price: BigDecimal(456.78, 10),
      number_of_service_fee_payments: 19,
      retention_points:
        {
          "Commencement": {
            retained_participants: 100,
          },
          "Retention 1": {
            retained_participants: 72,
          },
          "Retention 2": {
            retained_participants: 51,
          },
          "Completion": {
            retained_participants: 38,
          },
        },
    }
  end

  describe "#service_fee_schedule" do
    let(:result) { ::PaymentCalculator::Npq::PaymentCalculation.call(config) }

    it "includes config in the output" do
      expect(result[:input]).to eq(config)
    end

    it "returns BigDecimal for all money outputs" do
      result.dig(:output, :service_fees, :payment_schedule).each do |value|
        expect(value).to be_a(BigDecimal)
      end
    end
  end
end
