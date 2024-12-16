# frozen_string_literal: true

namespace :lead_providers do
  desc "create seed schools and participants for API testing"
  task seed_schools_and_participants: :environment do
    return unless Rails.env.in?(%w[development review sandbox])

    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    LeadProvider.all.map(&:name).each do |provider|
      ValidTestDataGenerators::ECFLeadProviderPopulater.call(name: provider, total_schools: 10, participants_per_school: 300)
    end
  end
end
