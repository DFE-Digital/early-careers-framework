# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

class DummyClass
  include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
end

describe ::PaymentCalculator::Ecf::Contract::ServiceFeeCalculations do
  it "performs calculations of the service fees" do
    band_a = double("Band Double", per_participant: 996.00,
                                   number_of_participants_in_this_band: 2000,
                                   deduction_for_setup?: true,
                                   upper_boundary: 2000)
    contract = double("Contract Double", recruitment_target: 2000, set_up_fee: 149_651.00, band_a: band_a)
    call_off_contract = DummyClass.new({ contract: contract })

    expect(call_off_contract.service_fee_total(band_a).round(0)).to eq(647_149.00)
    expect(call_off_contract.service_fee_monthly(band_a).round(0)).to eq(22_315.00)
    expect(call_off_contract.service_fee_per_participant(band_a).round(0)).to eq(324.00)
  end
end
