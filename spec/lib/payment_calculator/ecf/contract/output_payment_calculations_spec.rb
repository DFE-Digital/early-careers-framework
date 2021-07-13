# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"
class ModuleTestHarness
  include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
end

describe ::PaymentCalculator::Ecf::Contract::OutputPaymentCalculations do
  let(:contract) { build_stubbed(:call_off_contract) }
  let(:call_off_contract) { ModuleTestHarness.new({ contract: contract }) }

  context "when calculating output payments" do
    let(:band_a) { build_stubbed(:participant_band, min: 0, max: 100, per_participant: 996, call_off_contract: contract) }

    it "performs calculations of the output payments" do
      expect(call_off_contract.output_payment_per_participant(band_a)).to eq(597.60)

      %i[started completion].each do |event_type|
        expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type, band: band_a).round(0)).to eq(120.00)
      end

      %i[retention_1 retention_2 retention_3 retention_4].each do |event_type|
        expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type, band: band_a).round(0)).to eq(90.00)
      end
    end
  end

  context "when calculating output payment with total participants in multiple bands" do
    let(:band_a) { build_stubbed(:participant_band, min: 0, max: 200, per_participant: 100, call_off_contract: contract) }
    let(:band_b) { build_stubbed(:participant_band, min: 201, max: 400, per_participant: 200, call_off_contract: contract) }
    let(:band_c) { build_stubbed(:participant_band, min: 401, max: 500, per_participant: 300, call_off_contract: contract) }

    it "calculates subtotal based on banding total participants" do
      expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_a)).to eq(2400.00)
      expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_b)).to eq(4800.00)
      expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_c)).to eq(3600.00)

      expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 50, band: band_a)).to eq(600.00)
      expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 90, band: band_a)).to eq(1080.00)
    end
  end
end
