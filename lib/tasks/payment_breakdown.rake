# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "payment_calculator/ecf/uplift_calculation"
require "tasks/payment_breakdown"
require "terminal-table"

namespace :payment_calculation do
  include ActiveSupport::NumberHelper

  desc "run payment calculator for a given ECF lead provider"
  task breakdown: :environment do
    cpd_lead_provider = begin
      CpdLeadProvider.find(ARGV[1])
    rescue StandardError
      CpdLeadProvider.find_by(name: ARGV[1])
    end
    raise "Unknown lead provider: #{ARGV[1]}" if cpd_lead_provider.nil?
    raise "Not an ECF lead provider #{ARGV[1]}" if cpd_lead_provider.lead_provider.nil?

    aggregation_type = (ARGV[2] || "eligible" )
    raise "Unknown aggregation type: #{ARGV[2]}" unless %w[submitted eligible payable paid].include?(aggregation_type)
    total_participants = (ARGV[3] || ParticipantDeclaration::ECF.for_lead_provider(cpd_lead_provider).send(aggregation_type).count).to_i
    uplift_participants = (ARGV[4] || ParticipantDeclaration::ECF.uplift.for_lead_provider(cpd_lead_provider).send(aggregation_type).count).to_i
    total_ects = (ARGV[3].present? ? ARGV[3].to_i / 2 : ParticipantDeclaration::ECF.send(aggregation_type).ect.for_lead_provider(cpd_lead_provider).count)
    total_mentors = (ARGV[4].present? ? ARGV[4].to_i - ARGV[3].to_i / 2 : ParticipantDeclaration::ECF.send(aggregation_type).mentor.for_lead_provider(cpd_lead_provider).count)
    Tasks::PaymentBreakdown.new(contract: cpd_lead_provider.lead_provider.call_off_contract, total_participants: total_participants, uplift_participants: uplift_participants, total_ects: total_ects, total_mentors: total_mentors).to_table
  rescue StandardError => e
    puts e.message
    puts e.backtrace
  ensure
    exit
  end

  desc "generate csv payment calculations for all ECF lead providers"
  task csv: :environment do
    filename = (ARGV[1] || "output.csv")
    lead_providers = LeadProvider.all
    CSV.open(filename, "wb") do |csv|
      csv << Tasks::PaymentBreakdown.new(contract: lead_providers.first.call_off_contract, total_participants: 0, uplift_participants: 0).csv_headings
      lead_providers.each do |lead_provider|
        contract = lead_provider.call_off_contract
        total_participants = ParticipantDeclaration::ECF.payable.for_lead_provider(cpd_lead_provider).count
        uplift_participants = ParticipantDeclaration::ECF.payable.uplift_for_lead_provider(cpd_lead_provider).count
        total_ects = ParticipantDeclaration::ECF.payable.ects_for_lead_provider(cpd_lead_provider).count
        total_mentors = ParticipantDeclaration::ECF.payable.mentors_for_lead_provider(cpd_lead_provider).count
        csv << Tasks::PaymentBreakdown.new(contract: contract, total_participants: total_participants, uplift_participants: uplift_participants, total_ects: total_ects, total_mentors: total_mentors).csv_body
      end
    end
  rescue StandardError => e
    puts e.message
    puts e.backtrace
  ensure
    exit
  end
end
