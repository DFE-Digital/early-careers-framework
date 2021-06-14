# frozen_string_literal: true

require "payment_calculator/ecf/contract/uplift_payment_calculations"

class DummyClass
  include PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations
end

describe ::PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations do
  it "returns the expected types for uplift" do
    contract = double("Contract Double", uplift_amount: BigDecimal(100.00, 2))
    call_off_contract = DummyClass.new({ contract: contract })
    event_type = :started

    if @combined_results.nil?
      expect(call_off_contract.uplift_payment_per_participant.round(2)).to be_a(BigDecimal)
      expect(call_off_contract.uplift_payment_per_participant_for_event(event_type: event_type)).to be_a(BigDecimal)
      expect(call_off_contract.uplift_payment_for_event(event_type: event_type, total_participants: 100)).to be_a(BigDecimal)
    end
  end

  it "performs calculations of the uplift payments" do
    contract = double("Contract Double", uplift_amount: 100)
    call_off_contract = DummyClass.new({ contract: contract })
    total_participants = 330

    expect(call_off_contract.uplift_payment_per_participant.round(0)).to eq(100.00)

    %i[started].each do |event_type|
      expect(call_off_contract.uplift_payment_per_participant_for_event(event_type: event_type).round(2)).to eq(100.00)
      expect(call_off_contract.uplift_payment_for_event(event_type: event_type, total_participants: total_participants).round(2)).to eq(33_000.00)
    end

    %i[retention_1 retention_2 retention_3 retention_4 completion].each do |event_type|
      expect(call_off_contract.uplift_payment_per_participant_for_event(event_type: event_type).round(2)).to eq(0.00)
      expect(call_off_contract.uplift_payment_for_event(event_type: event_type, total_participants: total_participants.round(2))).to eq(0.00)
    end
  end
end
