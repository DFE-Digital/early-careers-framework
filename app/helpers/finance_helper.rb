# frozen_string_literal: true

module FinanceHelper
  MILESTONE_DATES = [
    "30.09.2021",
    "31.10.2021",
    "31.01.2022",
    "30.04.2022",
    "30.09.2022",
    "31.01.2023",
    "30.04.2023",
    "31.10.2023",
    "31.01.2024",
    "30.04.2024",
    "30.09.2024",
  ].freeze

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

  def payment_period
    index = MILESTONE_DATES.each_index.detect { |date| Time.zone.today.before?(Date.parse(MILESTONE_DATES[date])) }
    MILESTONE_DATES.slice(index - 1, 2)
  end

  def pretty_payment_period
    payment_period.map { |date| Date.parse(date).to_s(:govuk) }.join(" - ")
  end

  def cutoff_date
    Date.parse(payment_period.length < 2 ? MILESTONE_DATES[0] : payment_period[1]).to_s(:govuk)
  end
end
