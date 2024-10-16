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

  desc "create NPQ seed schools and participants for API testing"
  task seed_schools_and_participants_npq: :environment do
    return unless Rails.env.in?(%w[development review sandbox])

    NPQLeadProvider.name_order.joins(:cohorts).includes(:cohorts).find_each do |lp|
      Cohort.between_years((Date.current - 2.years + 1.day).year, (Date.current + 1.year).year).each do |c|
        ValidTestDataGenerators::NPQLeadProviderPopulater.populate(name: lp.name, total_schools: 10, participants_per_school: 10, cohort: c)
        ValidTestDataGenerators::PendingNPQApplicationsPopulater.populate(name: lp.name, number_of_participants: 100, cohort: c)
      end
    end
  end
end
