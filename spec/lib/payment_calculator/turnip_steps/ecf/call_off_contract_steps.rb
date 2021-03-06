# frozen_string_literal: true

module CallOffContractSteps
  class ModuleTestHarness
    include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
    include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
  end

  step "the set_up fee is £:decimal_placeholder" do |value|
    @set_up_fee = value
  end

  step "the recruitment target is :value" do |value|
    @recruitment_target = value.to_i
  end

  step "Band A per-participant price is £:decimal_placeholder" do |value|
    @per_participant_value = value
  end

  step "I setup the contract" do
    @band_a = double("Band Double", number_of_participants_in_this_band: 2000, per_participant: @per_participant_value, deduction_for_setup?: true)
    contract = double("Contract Double",
                      recruitment_target: @recruitment_target,
                      set_up_fee: @set_up_fee,
                      band_a: @band_a,
                      set_up_recruitment_basis: 2000)
    @call_off_contract = ModuleTestHarness.new({ contract: contract, per_participant: @per_participant_value })
  end

  step :assert_service_fee_per_participant, "the per-participant service fee should be reduced to £:decimal_placeholder"
  step :assert_service_fee_per_participant, "the per-participant service fee should be £:decimal_placeholder"

  step "the total service fee should be £:decimal_placeholder" do |expected_value|
    expect(@call_off_contract.service_fee_total(@band_a).round(0)).to eq(expected_value)
  end

  step "the monthly service fee should be £:decimal_placeholder" do |expected_value|
    expect(@call_off_contract.service_fee_monthly(@band_a).round(0)).to eq(expected_value)
  end

  step :assert_output_per_participant, "the output payment per-participant should be £:decimal_placeholder"
  step :assert_output_per_participant, "the output payment per-participant should be unchanged at £:decimal_placeholder"

  def assert_service_fee_per_participant(expected_value)
    expect(@call_off_contract.service_fee_per_participant(@band_a).round(2)).to eq(expected_value)
  end

  def assert_output_per_participant(expected_value)
    expect(@call_off_contract.output_payment_per_participant(@band_a).round(0)).to eq(expected_value)
  end
end

RSpec.configure do |config|
  config.include CallOffContractSteps, ecf: true
end
