# frozen_string_literal: true

module UpliftPaymentsSteps
  class DummyClass
    include PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations
  end

  step "An uplift per participant of £:decimal_placeholder" do |value|
    @uplift_amount = value
  end

  step "there are :sparsity sparsity and :pupil_premium pupil premium participants who have started that are eligible for the uplift payment" do |sparsity, pupil_premium|
    @uplift_eligible_participants = sparsity.to_i + pupil_premium.to_i
  end

  step "I setup the contract with uplift payment" do
    contract = double("Contract Double", uplift_amount: @uplift_amount)
    @call_off_contract = DummyClass.new({ contract: contract, bands: [] })
    calculator = PaymentCalculator::Ecf::PaymentCalculation.new(contract: @call_off_contract)
    @result = calculator.call(uplift_participants: @uplift_eligible_participants)
  end

  step "the total uplift payment should be £:decimal_placeholder" do |value|
    expect(@result.dig(:uplift, :sub_total)).to eq(value)
  end
end

RSpec.configure do |config|
  config.include UpliftPaymentsSteps, ecf: true
end
