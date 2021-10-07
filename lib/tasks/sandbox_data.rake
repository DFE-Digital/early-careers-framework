# frozen_string_literal: true

require "tasks/valid_test_data_generator"

namespace :lead_providers do
  desc "create seed schools and participants for API testing"
  task seed_schools_and_participants: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    LeadProvider.all.map(&:name).each do |provider|
      ValidTestDataGenerator::LeadProviderPopulater.call(name: provider, total_schools: 100, participants_per_school: 100)
    end
    ValidTestDataGenerator::AmbitionSpecificPopulater.call(name: "Ambition Institute", total_schools: 3, participants_per_school: 1500)
  end

  desc "create NPQ seed schools and participants for API testing"
  task seed_schools_and_participants_npq: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    NPQLeadProvider.all.map(&:name).each do |provider|
      ValidTestDataGenerator::NPQLeadProviderPopulater.call(name: provider, total_schools: 100, participants_per_school: 100)
    end
  end
end
