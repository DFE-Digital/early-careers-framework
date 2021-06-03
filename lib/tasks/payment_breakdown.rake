# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
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

    total_participants = ARGV[2].to_i || 2000
    per_participant = number_to_delimited(lead_provider.call_off_contract.band_a.per_participant.to_i)

    breakdown = PaymentCalculator::Ecf::PaymentCalculation.call(
      {
        lead_provider: lead_provider,
      },
      total_participants: total_participants,
      event_type: :start,
    )

    service_fee = number_to_delimited(breakdown.dig(:service_fees, :service_fee_monthly).to_i)
    output_payment = number_to_delimited(breakdown.dig(:output_payment, :start, :subtotal).to_i)

    output = <<-RESULT
      ---------------------------------------------
      |  Payment type            | Payment amount |
      ---------------------------------------------
      | Service fee (monthly)    |   £#{service_fee}      |
      | Output payment (started) |   £#{output_payment}     |
      ---------------------------------------------
      Based on #{number_to_delimited(total_participants.to_i)} participants and £#{per_participant} per participant
    RESULT

    logger.info output
  rescue StandardError
    logger.info "Lead provider for '#{ARGV[1]}' not found"
  ensure
    exit(0)
  end
end
