# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalculationOrchestrator do
  let(:call_off_contract) { create(:call_off_contract) }
  let(:expected_result) do
    {
      service_fees: {
        service_fee_monthly: 22_287.90,
        service_fee_per_participant: 323.17,
        service_fee_total: 646_349.0,
      },
      output_payment: {
        per_participant: 597.0,
        start: {
          per_participant: 119.4,
          retained_participants: 10,
          subtotal: 1_194.0,
        },
      },
    }
  end

  before do
    10.times do
      pr = create(:participation_record, lead_provider: call_off_contract.lead_provider)
      pr.join!
      create(:participation_record, lead_provider: call_off_contract.lead_provider)
    end
  end

  context ".call" do
    it "returns the total calculation" do
      expect(described_class.call({ lead_provider: call_off_contract.lead_provider }, event_type: :start)).to eq(expected_result)
    end
  end
end
