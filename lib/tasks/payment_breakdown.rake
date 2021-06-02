# frozen_string_literal: true

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

    breakdown = CalculationOrchestrator.call({ lead_provider: lead_provider }, event_type: :start)
    logger.info JSON.pretty_generate(breakdown)
  rescue StandardError
    logger.info "Lead provider for '#{ARGV[1]}' not found"
  ensure
    exit(0)
  end
end
