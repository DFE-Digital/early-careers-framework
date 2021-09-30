# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentCalculator::ECF::Contract::UpliftPaymentCalculations do
  let(:dummy_class) { Class.new { include PaymentCalculator::ECF::Contract::UpliftPaymentCalculations } }
  let(:call_off_contract) { create(:call_off_contract) }
  let(:calculator) { dummy_class.new({ contract: call_off_contract }) }

  it "returns the uplift_payment_per_participant" do
    expect(calculator.uplift_payment_per_participant).to eq(100)
  end

  it "returns the expected uplift_payment_per_participant for a each event type" do
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :started)).to eq(100)
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :retained_1)).to eq(0)
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :retained_2)).to eq(0)
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :retained_3)).to eq(0)
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :retained_4)).to eq(0)
    expect(calculator.uplift_payment_per_participant_for_event(event_type: :completed)).to eq(0)
  end

  it "returns a capped uplift_payment_for_events when the total exceeds 5% of the total contract value" do
    expect(calculator.uplift_payment_for_event(uplift_participants: 10_000, event_type: :started)).to eq(99_500)
  end
end
