# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"
class DummyClass
  include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
end

describe ::PaymentCalculator::Ecf::Contract::OutputPaymentCalculations do
  let(:contract) { create(:call_off_contract) }
  let(:band_a) { create(:participant_band, min: 0, max: 200, per_participant: 100, call_off_contract: contract) }
  let(:band_b) { create(:participant_band, min: 201, max: 400, per_participant: 200, call_off_contract: contract) }
  let(:band_c) { create(:participant_band, min: 401, max: 500, per_participant: 300, call_off_contract: contract) }

  it "performs calculations of the output payments" do
    band_a = double("Band Double", per_participant: 996.00)
    contract = double("Contract Double", band_a: band_a)
    call_off_contract = DummyClass.new({ contract: contract })

    expect(call_off_contract.output_payment_per_participant(band_a).round(0)).to eq(598.00)

    %i[started completion].each do |event_type|
      expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type, band: band_a).round(0)).to eq(120.00)
    end

    %i[retention_1 retention_2 retention_3 retention_4].each do |event_type|
      expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type, band: band_a).round(0)).to eq(90.00)
    end
  end

  it "calculates subtotal based on banding total participants" do
    contract = double("Contract Double", band_a: band_a)
    call_off_contract = DummyClass.new({ contract: contract, band_a: band_a, band_b: band_b, band_c: band_c })

    expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_a)).to eq(2400.00)
    expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_b)).to eq(4800.00)
    expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 500, band: band_c)).to eq(3600.00)

    expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 50, band: band_a)).to eq(600.00)
    expect(call_off_contract.output_payment_for_event(event_type: :started, total_participants: 90, band: band_a)).to eq(1080.00)
  end
end
