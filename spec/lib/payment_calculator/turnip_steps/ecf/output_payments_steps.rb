# frozen_string_literal: true

module OutputPaymentsSteps
  class DummyClass
    include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
    include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations
  end

  step "there are the following retention numbers:" do |table|
    @retention_table = table.hashes.map do |values|
      {
        payment_type: values["Payment Type"],
        retained_participants: values["Retained Participants"].to_i,
        expected_per_participant_output_payment: CurrencyParser.currency_to_big_decimal(values["Expected Per-Participant Output Payment"]),
        expected_output_payment_subtotal: CurrencyParser.currency_to_big_decimal(values["Expected Output Payment Subtotal"]),
      }
    end
  end

  step "I run each calculation" do
    @band_a = double("Band Double", per_participant: @per_participant_value, number_of_participants_in_this_band: 2000, deduction_for_setup?: true, upper_boundary: 2000)
    contract = double("Contract Double", recruitment_target: @recruitment_target, set_up_fee: @set_up_fee, band_a: @band_a)
    @call_off_contract = DummyClass.new({ contract: contract, bands: [@band_a] })
    lead_provider = double("Lead Provider", call_off_contract: @call_off_contract)
    calculator = PaymentCalculator::Ecf::PaymentCalculation.new(lead_provider: lead_provider)
    @result = @retention_table.map do |row|
      calculator.call(event_type: row[:payment_type], total_participants: row[:retained_participants])
    end
  end

  step "the output payment schedule should be as above" do
    aggregate_failures "output payments" do
      expect(@result.length).to eq(@retention_table.length)
      @retention_table.length.times.each do |x|
        key = @retention_table[x][:payment_type]
        actual_values = @result[x][:output_payment][key]
        expectation = @retention_table[x]
        expect_with_context(actual_values[:retained_participants], expectation[:retained_participants], "#{expectation[:payment_type]} retention numbers passthrough")
        expect_with_context(actual_values[:per_participant], expectation[:expected_per_participant_output_payment], "#{expectation[:payment_type]} per participant payment")
        expect_with_context(actual_values[:subtotal], expectation[:expected_output_payment_subtotal], "#{expectation[:payment_type]} output payment")
      end
    end
  end
end

RSpec.configure do |config|
  config.include OutputPaymentsSteps, ecf: true
end
