# frozen_string_literal: true

module PaymentCalculationSteps
  step "the setup fee is £:decimal_placeholder" do |value|
    @setup_fee = value
  end

  step "the recruitment target is :decimal_placeholder" do |value|
    @recruitment_target = value
  end

  step "Band A per-participant price is £:decimal_placeholder" do |value|
    @band_a = value
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

  step "I run the calculation" do
    config = {
      setup_fee: @setup_fee,
      recruitment_target: @recruitment_target,
      band_a: @band_a,
      retained_participants: @retention_table&.reduce({}) { |res, hash| res.merge({ hash[:payment_type] => hash[:retained_participants] }) },
    }
    calculator = Services::Ecf::PaymentCalculation.new(config)
    @result = calculator.call
  end

  step :assert_service_fee_per_participant, "the per-participant service fee should be reduced to £:decimal_placeholder"
  step :assert_service_fee_per_participant, "the per-participant service fee should be £:decimal_placeholder"

  step "the total service fee should be £:decimal_placeholder" do |expected_value|
    expect(@result.dig(:output, :service_fees, :service_fee_total)).to eq(expected_value)
  end

  step "the monthly service fee should be £:decimal_placeholder" do |expected_value|
    expect(@result.dig(:output, :service_fees, :service_fee_monthly)).to eq(expected_value)
  end

  step :assert_output_per_participant, "the output payment per-participant should be £:decimal_placeholder"
  step :assert_output_per_participant, "the output payment per-participant should be unchanged at £:decimal_placeholder"

  step "the output payment schedule should be as above" do
    aggregate_failures "output payments" do
      actual_schedule = @result.dig(:output, :output_payment, :output_payment_schedule)
      expect(actual_schedule.length).to eq(@retention_table.length)
      @retention_table.each do |expectation|
        actual_values = actual_schedule[expectation[:payment_type]]
        expect_with_context(actual_values[:retained_participants], expectation[:retained_participants], "#{expectation[:payment_type]} retention numbers passthrough")
        expect_with_context(actual_values[:per_participant], expectation[:expected_per_participant_output_payment], "#{expectation[:payment_type]} per participant payment")
        expect_with_context(actual_values[:subtotal], expectation[:expected_output_payment_subtotal], "#{expectation[:payment_type]} output payment")
      end
    end
  end

  def assert_service_fee_per_participant(expected_value)
    expect(@result.dig(:output, :service_fees, :service_fee_per_participant)).to eq(expected_value)
  end

  def assert_output_per_participant(expected_value)
    expect(@result.dig(:output, :output_payment, :per_participant)).to eq(expected_value)
  end
end

RSpec.configure do |config|
  config.include PaymentCalculationSteps, ecf: true
end
