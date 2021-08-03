# frozen_string_literal: true

module UpliftPaymentsSteps
  class ModuleTestHarness
    include PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations
  end

  step "An uplift per participant of £:decimal_placeholder" do |value|
    @uplift_amount = value
  end

  step "there are :value sparsity participants who have started that are eligible for the uplift payment" do |value|
    @uplift_eligible_participants = value.to_i
  end

  step "there are :value pupil premium participants who have started that are eligible for the uplift payment" do |value|
    @uplift_eligible_participants += value.to_i
  end

  step "I setup the contract with uplift payment" do
    contract = double("Contract Double", uplift_amount: @uplift_amount)
    @call_off_contract = ModuleTestHarness.new({ contract: contract, bands: [] })
    calculator = PaymentCalculator::Ecf::PaymentCalculation.new(contract: @call_off_contract)
    @result = calculator.call(uplift_participants: @uplift_eligible_participants)
  end

  step "the total uplift payment should be £:decimal_placeholder" do |value|
    expect(@result.dig(:uplift, :subtotal)).to eq(value)
  end
end

RSpec.configure do |config|
  config.include UpliftPaymentsSteps, ecf: true
end
