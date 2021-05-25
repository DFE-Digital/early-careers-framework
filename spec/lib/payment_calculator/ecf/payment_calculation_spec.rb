# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

describe ::PaymentCalculator::Ecf::PaymentCalculation do
  let(:contract) do
    FactoryBot.create(:call_off_contract)
  end

  let(:retained_event_aggregations) do
    {
      "Start" => 1900,
      "Retention 1" => 1700,
      "Retention 2" => 1500,
      "Retention 3" => 1000,
      "Retention 4" => 800,
      "Completion" => 500,
    }
  end

  let(:config) do
    {
      contract: contract,
    }
  end

  @combined_results = nil

  it "returns the expected types for all outputs" do
    retained_event_aggregations.each do |key, value|
      result = described_class.call(config, event_type: key, total_participants: value)

      if @combined_results.nil?
        expect(result.dig(:service_fees, :service_fee_per_participant)).to be_a(BigDecimal)
        expect(result.dig(:service_fees, :service_fee_total)).to be_a(BigDecimal)
        expect(result.dig(:service_fees, :service_fee_monthly)).to be_a(BigDecimal)
        expect(result.dig(:output_payment, :per_participant)).to be_a(BigDecimal)
      end

      @combined_results ||= { service_fees: result[:service_fees], output_payment: {} }
      @combined_results[:output_payment][key] = result.dig(:output_payment, key)
    end

    @combined_results[:output_payment].each do |key, value|
      expect(key).to be_a(String)
      expect(value[:retained_participants]).to be_an(Integer)
      expect(value[:per_participant]).to be_a(BigDecimal)
      expect(value[:subtotal]).to be_a(BigDecimal)
    end
  end
end
