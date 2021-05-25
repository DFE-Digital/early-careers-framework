# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"
class DummyClass
  include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
end

describe ::PaymentCalculator::Ecf::Contract::OutputPaymentCalculations do

  it "performs calculations of the output payments" do
    band_a=double("Band Double", per_participant: 996.00)
    contract=double("Contract Double", band_a: band_a)
    call_off_contract=DummyClass.new({contract: contract})

    expect(call_off_contract.output_payment_per_participant.round(0)).to eq(598.00)

    %i[start completion].each do |event_type|
      expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type).round(0)).to eq(120.00)
    end

    %i[retention_1 retention_2 retention_3 retention_4].each do |event_type|
      expect(call_off_contract.output_payment_per_participant_for_event(event_type: event_type).round(0)).to eq(90.00)
    end
  end
end
