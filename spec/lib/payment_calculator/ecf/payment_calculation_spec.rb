# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

describe ::PaymentCalculator::Ecf::PaymentCalculation do
  let(:contract) do
    FactoryBot.create(:call_off_contract)
  end

  let(:start_event_name) { "Started" }
  let(:participant_for_event) { 1900 }

  let(:retained_event_aggregations) do
    {
      "Started" => 1900,
      "Retention 1" => 1700,
      "Retention 2" => 1500,
      "Retention 3" => 1000,
      "Retention 4" => 800,
      "Completion" => 500,
    }
  end

  let(:params) do
    {
      contract: contract,
    }
  end

  it "returns the expected types for all outputs" do
    retained_event_aggregations.each do |key, value|
      result = described_class.call(contract: contract, event_type: key, total_participants: value)

      result.dig(:service_fees).each do |service_fee|
        expect(service_fee[:service_fee_per_participant]).to be_a(BigDecimal)
        expect(service_fee[:service_fee_total]).to be_a(BigDecimal)
        expect(service_fee[:service_fee_monthly]).to be_a(BigDecimal)
      end
    end

    result = described_class.call(contract: contract, event_type: start_event_name, total_participants: participant_for_event)

    result.dig(:output_payments).each do |output_payment|
      expect(output_payment.dig(start_event_name, :retained_participants)).to be_an(Integer)
      expect(output_payment.dig(start_event_name, :per_participant)).to be_an(BigDecimal)
    end
  end
end
