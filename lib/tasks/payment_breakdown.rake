# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "payment_calculator/ecf/uplift_calculation"
require "terminal-table"

include ActiveSupport::NumberHelper

namespace :payment_calculation do
  desc "run payment calculator for a given lead provider"
  task breakdown: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    begin
      lead_provider = LeadProvider.find(ARGV[1])
    rescue StandardError
      lead_provider = LeadProvider.find_by(name: ARGV[1])
    end

    total_participants = (ARGV[2] || 2000).to_i
    uplift_participants = (ARGV[3] || 200).to_i
    per_participant_in_bands = lead_provider.call_off_contract.bands.each_with_index.map { |b, i| "£#{b.per_participant.to_i} per participant in #{band_name_from_index(i)}" }.join(", ")

    breakdown = PaymentCalculator::Ecf::PaymentCalculation.call(
      contract: lead_provider.call_off_contract,
      total_participants: total_participants,
      uplift_participants: uplift_participants,
      event_type: :started,
    )

    service_fees = breakdown.dig(:service_fees).each_with_object([]) do |hash, bands|
      bands << [
        band_name_from_index(bands.length),
        "£#{number_to_delimited(hash[:service_fee_per_participant].to_i)}",
        "£#{number_to_delimited(hash[:service_fee_monthly].to_i)}",
      ]
    end

    output_payments = breakdown.dig(:output_payments).each_with_object([]) do |hash, bands|
      bands << [
        band_name_from_index(bands.length),
        "£#{number_to_delimited(hash.dig(:started, :per_participant).to_i)}",
        "£#{number_to_delimited(hash.dig(:started, :subtotal).to_i)}",
      ]
    end

    uplift_payment = breakdown[:uplift].each_with_object({}) do |(type, value), hash|
      hash[type] = "£#{number_to_delimited(value.to_i)}"
    end

    table = Terminal::Table.new(
      title: "Started Event Payments",
      headings: ["", "Service fee\nPer Participant", "Service fee\nThis month"],
      rows: service_fees,
    )
    table.style = { alignment: :center }
    table.add_separator
    table.add_row ["", "Output price", "Output price"]
    table.add_row ["", "Per Participant", "Sub-total"]
    table.add_separator
    output_payments.each { |row| table.add_row(row) }
    table.add_separator
    table.add_row ["", "Per participant", "Total Uplift"]
    table.add_separator
    table.add_row(["Uplift", uplift_payment[:per_participant], uplift_payment[:sub_total]])

    output = <<~RESULT
      Based on #{number_to_delimited(total_participants.to_i)} participants and #{per_participant_in_bands}
    RESULT
    logger.info table
    logger.info output
  end
end

def band_name_from_index(index)
  "Band #{('A'..'Z').to_a[index]}"
end
