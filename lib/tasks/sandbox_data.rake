# frozen_string_literal: true

require "tasks/valid_test_data_generator"

namespace :lead_providers do
  desc "create seed schools and participants for API testing"
  task seed_schools_and_participants: :environment do
    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    ["Capita", "Teach First", "UCL Institute of Education", "Best Practice Network", "Ambition Institute", "Education Development Trust"].each do |provider|
      ValidTestDataGenerator::LeadProviderPopulator.call(name: provider, total_schools: 100, participants_per_school: 100)
    end
  end
end
