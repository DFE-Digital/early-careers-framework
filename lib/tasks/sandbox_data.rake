# frozen_string_literal: true

require "tasks/valid_test_data_generator"
require "tasks/valid_test_data_generator/npq_lead_provider_populater"
require "tasks/valid_test_data_generator/pending_npq_applications_populater"

namespace :lead_providers do
  desc "create seed schools and participants for API testing"
  task seed_schools_and_participants: :environment do
    return unless Rails.env.in?(%w[development review sandbox])

    logger = Logger.new($stdout)
    logger.formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end

    LeadProvider.all.map(&:name).each do |provider|
      ValidTestDataGenerator::LeadProviderPopulater.call(name: provider, total_schools: 10, participants_per_school: 300)
    end
  end

  desc "create NPQ seed schools and participants for API testing"
  task seed_schools_and_participants_npq: :environment do
    return unless Rails.env.in?(%w[development review sandbox])

    NPQLeadProvider.name_order.joins(:cohorts).includes(:cohorts).find_each do |lp|
      Cohort.between_years((Date.current - 2.years + 1.day).year, (Date.current + 1.year).year).each do |c|
        ValidTestDataGenerator::NPQLeadProviderPopulater.populate(name: lp.name, total_schools: 100, participants_per_school: 100, cohort: c)
        ValidTestDataGenerator::PendingNPQApplicationsPopulater.populate(name: lp.name, number_of_participants: 100, cohort: c)
      end
    end
  end
end
