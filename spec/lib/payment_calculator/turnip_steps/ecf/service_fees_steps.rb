# frozen_string_literal: true

module ServiceFeeSteps
  class ModuleTestHarness
    include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
    include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
    include PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations
  end

  step "I run the calculation" do
    @band_a = double("Band Double", per_participant: @per_participant_value, number_of_participants_in_this_band: 2000, deduction_for_setup?: true)
    contract = double("Contract Double",
                      recruitment_target: @recruitment_target,
                      set_up_fee: @set_up_fee,
                      band_a: @band_a,
                      bands: [@band_a],
                      uplift_amount: 100,
                      set_up_recruitment_basis: 2000)
    @call_off_contract = ModuleTestHarness.new({ contract: contract,
                                                 bands: [@band_a] })
    calculator = PaymentCalculator::Ecf::PaymentCalculation.new(contract: @call_off_contract)
    @result = calculator.call
  end
end

RSpec.configure do |config|
  config.include ServiceFeeSteps, ecf: true
end
