# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "payment_calculator/ecf/uplift_calculation"
require "tasks/payment_breakdown"
require "terminal-table"

include ActiveSupport::NumberHelper

namespace :payment_calculation do
  desc "run payment calculator for a given ECF lead provider"
  task breakdown: :environment do
    cpd_lead_provider = begin
                      CpdLeadProvider.find(ARGV[1])
                        rescue StandardError
                          CpdLeadProvider.find_by(name: ARGV[1])
                    end
    raise "Unknown lead provider: #{ARGV[1]}" if cpd_lead_provider.nil?
    raise "Not an ECF lead provider #{ARGV[1]}" if cpd_lead_provider.lead_provider.nil?

    total_participants = (ARGV[2] || ParticipantDeclaration::ECF.active_for_lead_provider(cpd_lead_provider).payable.count)
    uplift_participants = (ARGV[3] || ParticipantDeclaration::ECF.active_uplift_for_lead_provider(cpd_lead_provider).payable.count)
    total_ects = (ARGV[2].present? ? ARGV[2].to_i / 2 : ParticipantDeclaration::ECF.active_ects_for_lead_provider(cpd_lead_provider).payable.count)
    total_mentors = (ARGV[2].present? ? ARGV[2].to_i - ARGV[2].to_i / 2 : ParticipantDeclaration::ECF.active_mentors_for_lead_provider(cpd_lead_provider).payable.count)
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
        total_participants = ParticipantDeclaration::ECF.active_for_lead_provider(cpd_lead_provider).payable.count
        uplift_participants = ParticipantDeclaration::ECF.active_uplift_for_lead_provider(cpd_lead_provider).payable.count
        total_ects = ParticipantDeclaration::ECF.active_ects_for_lead_provider(cpd_lead_provider).payable.count
        total_mentors = ParticipantDeclaration::ECF.active_mentors_for_lead_provider(cpd_lead_provider).payable.count
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
