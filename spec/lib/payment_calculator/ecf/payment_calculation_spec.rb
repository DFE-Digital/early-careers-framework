# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

describe ::PaymentCalculator::Ecf::PaymentCalculation do
  let(:contract) { FactoryBot.build_stubbed(:call_off_contract) }

  describe ".call" do
    {
      "Started" => 1900,
      "Retention 1" => 1700,
      "Retention 2" => 1500,
      "Retention 3" => 1000,
      "Retention 4" => 800,
      "Completion" => 500,
    }.each do |event_name, retained_participants|
      it "returns the expected types for '#{event_name}' event" do
        result = described_class.call(contract: contract, event_type: event_name, total_participants: retained_participants)

        result.dig(:service_fees).each do |service_fee|
          expect(service_fee[:service_fee_per_participant]).to be_a(BigDecimal)
          expect(service_fee[:service_fee_total]).to be_a(BigDecimal)
          expect(service_fee[:service_fee_monthly]).to be_a(BigDecimal)
        end

        result.dig(:output_payments).each do |output_payment|
          expect(output_payment.dig(event_name, :retained_participants)).to be_an(Integer)
          expect(output_payment.dig(event_name, :per_participant)).to be_an(BigDecimal)
        end
      end
    end
  end
end
