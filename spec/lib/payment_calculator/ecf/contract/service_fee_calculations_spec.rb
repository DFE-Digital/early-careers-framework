# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

class ModuleTestHarness
  include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
end

describe ::PaymentCalculator::Ecf::Contract::ServiceFeeCalculations do
  [
    {
      set_up_fee: 149_651.00,
      band_a_per_participant_price: 996.00,
      expected_total: 647_149.00,
      expected_monthly: 22_315.48,
      expected_per_participant: 323.57,
    },
    {
      set_up_fee: 150_000,
      band_a_per_participant_price: 995.00,
      expected_total: 646_000.00,
      expected_monthly: 22_275.86,
      expected_per_participant: 323.00,
    },
    {
      set_up_fee: 150_000,
      band_a_per_participant_price: 1_350.00,
      expected_total: 930_000.00,
      expected_monthly: 32_068.97,
      expected_per_participant: 465.00,
    },
  ].each do |example|
    it "performs calculations of the service fees (set_up_fee: #{example[:set_up_fee]}, band_a_per_participant_price: #{example[:band_a_per_participant_price]})" do
      band_a = double("Band Double",
                      per_participant: example[:band_a_per_participant_price],
                      number_of_participants_in_this_band: 2000,
                      deduction_for_setup?: true)
      contract = double("Contract Double",
                        recruitment_target: 2000,
                        set_up_fee: example[:set_up_fee],
                        band_a: band_a,
                        set_up_recruitment_basis: 2000)
      call_off_contract = ModuleTestHarness.new({ contract: contract })

      aggregate_failures do
        expect(call_off_contract.service_fee_total(band_a).round(2)).to eq(example[:expected_total])
        expect(call_off_contract.service_fee_monthly(band_a).round(2)).to eq(example[:expected_monthly])
        expect(call_off_contract.service_fee_per_participant(band_a).round(2)).to eq(example[:expected_per_participant])
      end
    end
  end
end
