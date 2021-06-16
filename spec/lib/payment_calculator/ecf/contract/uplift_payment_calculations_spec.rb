# frozen_string_literal: true

require "payment_calculator/ecf/contract/uplift_payment_calculations"
class DummyClass
  include PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations
end

describe ::PaymentCalculator::Ecf::Contract::UpliftPaymentCalculations do
  it "performs calculations of the uplift payments" do
    contract = double("Contract Double", uplift_amount: 100.0)
    call_off_contract = DummyClass.new({ contract: contract })

    expect(call_off_contract.uplift_payment_per_participant.round(0)).to eq(100.00)
    expect(call_off_contract.total_uplift_payment(30).round(0)).to eq(3_000.00)
  end
end
