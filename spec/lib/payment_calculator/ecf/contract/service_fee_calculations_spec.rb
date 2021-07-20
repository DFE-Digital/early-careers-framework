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
      test_service_fees(
        band_a_per_participant_price: example[:band_a_per_participant_price],
        set_up_fee: example[:set_up_fee],
        expected_total: example[:expected_total],
        expected_monthly: example[:expected_monthly],
        expected_per_participant: example[:expected_per_participant],
      )
    end
  end

  describe "the effect of a set up fee" do
    context "with a band_a_per_participant_price of £1,400" do
      let(:band_a_per_participant_price) { 1_400.00 }

      context "without a setup fee" do
        let(:set_up_fee) { 0 }

        it "doesn't change the calculated service fees" do
          test_service_fees(
            band_a_per_participant_price: band_a_per_participant_price,
            set_up_fee: set_up_fee,
            expected_total: 1_120_000.00,
            expected_monthly: 38_620.69,
            expected_per_participant: 560.00,
          )
        end
      end

      context "with a setup fee" do
        let(:set_up_fee) { 150_000 }

        it "reduces the calculated service fees" do
          test_service_fees(
            band_a_per_participant_price: band_a_per_participant_price,
            set_up_fee: set_up_fee,
            expected_total: 970_000.00,
            expected_monthly: 33_448.28,
            expected_per_participant: 485.00,
          )
        end
      end
    end
  end
end

def test_service_fees(band_a_per_participant_price:, set_up_fee:, expected_total:, expected_monthly:, expected_per_participant:)
  band_a = double("Band Double",
                  per_participant: band_a_per_participant_price,
                  number_of_participants_in_this_band: 2000,
                  deduction_for_setup?: true)
  contract = double("Contract Double",
                    recruitment_target: 2000,
                    set_up_fee: set_up_fee,
                    band_a: band_a,
                    set_up_recruitment_basis: 2000)
  call_off_contract = ModuleTestHarness.new({ contract: contract })

  aggregate_failures do
    expect(call_off_contract.service_fee_total(band_a).round(2)).to eq(expected_total)
    expect(call_off_contract.service_fee_monthly(band_a).round(2)).to eq(expected_monthly)
    expect(call_off_contract.service_fee_per_participant(band_a).round(2)).to eq(expected_per_participant)
  end
end
