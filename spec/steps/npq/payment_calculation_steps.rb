# frozen_string_literal: true

module PaymentCalculationSteps
  step "there's a qualification with a per-participant price of £:decimal_placeholder" do |value|
    @price_per_participant = value
  end

  step "the recruitment target is :value" do |value|
    @recruitment_target = value.to_i
  end

  step "there are :value monthly service fee payments" do |value|
    @number_of_service_fee_payments = value.to_i
  end

  step "the service fee payment schedule should be:" do |table|
    result = calculate
    aggregate_failures "service fees" do
      total_payment = 0
      table.hashes.each do |row|
        month_index = row["Month"].to_i
        expected_service_fee_total = CurrencyParser.currency_to_big_decimal(row["Service Fee"])
        total_payment += expected_service_fee_total
        expect_with_context(result.dig(:output, :service_fees, :payment_schedule)[month_index - 1], expected_service_fee_total, "Payment for month '#{month_index}'")
      end

      expect_with_context(@number_of_service_fee_payments, table.hashes.count, "Number of schedule payments")
      expect_with_context(total_payment, result.dig(:output, :service_fees, :payment_schedule).sum, "Total schedule payment")
    end
  end

  step "the service fee total should be £:decimal_placeholder" do |expected_amount|
    @expected_service_fee_total = expected_amount
    result = calculate
    expect(result.dig(:output, :service_fees, :total)).to eq(expected_amount)
  end

  step "the service fee schedule total should be the same as the service fee total" do
    result = calculate
    expect(result.dig(:output, :service_fees, :payment_schedule).sum).to eq(@expected_service_fee_total)
  end

  step "there are the following retention points:" do |table|
    @retention_table = {}

    table.hashes.each do |row|
      @retention_table[row["Payment Type"]] = {
        retained_participants: row["Retained Participants"].to_i,
        expected_per_participant_output_payment: CurrencyParser.currency_to_big_decimal(row["Expected Per-Participant Output Payment"]),
        expected_output_payment_subtotal: CurrencyParser.currency_to_big_decimal(row["Expected Output Payment Subtotal"]),
      }
    end
  end

  def calculate
    retention_points = {}
    @retention_table.each do |retention_point, values|
      retention_points[retention_point] = {
        retained_participants: values[:retained_participants],
        percentage: values[:percentage],
      }
    end

    config = {
      recruitment_target: @recruitment_target,
      number_of_service_fee_payments: @number_of_service_fee_payments,
      per_participant_price: @price_per_participant,
      retention_points: retention_points,
    }
    Services::Npq::PaymentCalculation.call(config)
  end

  step "expected output payments should be as above" do
    result = calculate
    aggregate_failures "output payments" do
      @retention_table.each do |retention_point, values|
        expect_with_context(
          result.dig(:output, :output_payment, retention_point, :per_participant), values[:expected_per_participant_output_payment], "Payment for retention point '#{retention_point}'"
        )

        expect_with_context(
          result.dig(:output, :output_payment, retention_point, :total_output_payment), values[:expected_output_payment_subtotal], "Total output payment '#{retention_point}'"
        )
      end
    end
  end
end

RSpec.configure do |config|
  config.include PaymentCalculationSteps, npq: true
end
