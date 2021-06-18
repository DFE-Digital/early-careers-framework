# frozen_string_literal: true

require "payment_calculator/ecf/uplift_calculation"

describe ::PaymentCalculator::Ecf::UpliftCalculation do
  let(:contract) do
    FactoryBot.create(:call_off_contract)
  end

  let(:retained_events) do
    %i[started retained_1 retained_2 retained_3 retained_4 completed]
  end

  let(:total_participants_eligible) { 330 }

  let(:params) do
    {
      contract: contract,
    }
  end

  it "returns the expected types for all outputs" do
    @combined_results = nil
    retained_events.each do |key|
      result = described_class.call(contract: contract, event_type: key, total_participants: total_participants_eligible)

      if @combined_results.nil?
        expect(result.dig(:per_participant)).to be_a(BigDecimal)
        expect(result.dig(:sub_total)).to be_a(BigDecimal)
      end

      @combined_results ||= { uplift_payment: result }
    end

    @combined_results[:uplift_payment].each do |_, value|
      expect(value).to be_a(BigDecimal)
    end
  end
end
