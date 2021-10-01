# frozen_string_literal: true

module FinanceHelper
  def number_to_pounds(number)
    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end

  def total_payment(breakdown)
    service_fee = Finance::ECF::ServiceFees.new(service_fees: breakdown[:service_fees]).monthly
    output_payment = Finance::ECF::OutputPayments.new(output_payments: breakdown[:output_payments]).subtotal
    other_fees = breakdown[:other_fees].map { |other_fee| Finance::ECF::OtherFeeRow.new(other_fee: Finance::ECF::OtherFee.new(other_fee)).subtotal }.inject(&:+)
    service_fee + output_payment + other_fees
  end

  def total_vat(breakdown)
    total_payment(breakdown) * 0.2
  end
end
