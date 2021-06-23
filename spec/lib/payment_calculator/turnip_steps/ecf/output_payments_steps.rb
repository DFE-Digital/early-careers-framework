# frozen_string_literal: true

require "./app/models/lead_provider"
require "./app/models/participant_band"
require "./app/models/call_off_contract"

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
    lead_provider = LeadProvider.create!(name: "Lead Provider")
    contract = CallOffContract.create!(
      lead_provider: lead_provider,
      recruitment_target: 2000,
      set_up_fee: 150_000,
    )
    @band_a = ParticipantBand.create!(call_off_contract: contract,
                                      min: 0,
                                      max: 2000,
                                      per_participant: @per_participant_value)

    @call_off_contract = DummyClass.new({ contract: contract, bands: [@band_a] })
    calculator = PaymentCalculator::Ecf::PaymentCalculation.new(contract: @call_off_contract)
    @result = @retention_table.map do |row|
      calculator.call(event_type: row[:payment_type], total_participants: row[:retained_participants])
    end
  end

  step "the output payment schedule should be as above" do
    aggregate_failures "output payments" do
      expect(@result.length).to eq(@retention_table.length)
      @retention_table.length.times.each do |row|
        key = @retention_table[row][:payment_type]
        @result[row][:output_payments].each do |output_payment|
          actual_values = output_payment[key]
          expectation = @retention_table[row]
          expect_with_context(actual_values[:retained_participants], expectation[:retained_participants], "#{expectation[:payment_type]} retention numbers passthrough")
          expect_with_context(actual_values[:per_participant], expectation[:expected_per_participant_output_payment], "#{expectation[:payment_type]} per participant payment")
          expect_with_context(actual_values[:subtotal], expectation[:expected_output_payment_subtotal], "#{expectation[:payment_type]} output payment")
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include OutputPaymentsSteps, ecf: true
end
