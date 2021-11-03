# frozen_string_literal: true

module FinanceHelper
  def number_to_pounds(number)
    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end

  def total_payment(breakdown)
    service_fee = breakdown[:service_fees].map { |params| params[:monthly] }.inject(&:+)
    output_payment = breakdown[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
    other_fees = breakdown[:other_fees].values.map { |other_fee| other_fee[:subtotal] }.inject(&:+)

    service_fee + output_payment + other_fees
  end

  def total_vat(breakdown, lead_provider)
    total_payment(breakdown) * (lead_provider.vat_chargeable ? 0.2 : 0.0)
  end
end
