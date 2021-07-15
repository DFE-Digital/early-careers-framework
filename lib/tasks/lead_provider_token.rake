# frozen_string_literal: true

namespace :lead_provider do
  desc "creates API token for lead provider ID parameter"
  task generate_token: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    name_or_id = ARGV[1]

    lead_provider = CpdLeadProvider.find_by(id: name_or_id) || CpdLeadProvider.find_by(name: name_or_id)

    raise "CpdLeadProvider '#{name_or_id}' not found" unless lead_provider

    token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: lead_provider)
    logger.info "Generated LeadProviderApiToken for CpdLeadProvider (#{lead_provider.id}): #{token}"

    exit(0) # to prevent re-processing args as additional rake tasks
  end
end
