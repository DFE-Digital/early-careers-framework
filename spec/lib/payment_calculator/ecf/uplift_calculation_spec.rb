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
    retained_events.each do |key|
      result = described_class.call(contract: contract, event_type: key, total_participants: total_participants_eligible)
      expect(result.dig(:uplift, :per_participant)).to be_a(BigDecimal)
      expect(result.dig(:uplift, :subtotal)).to be_a(BigDecimal)
    end
  end
end
