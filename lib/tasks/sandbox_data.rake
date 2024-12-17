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

  desc "seed good test data for lead providers for API testing"
  task :seed_statements_and_applications, %i[lead_provider_name participants_per_school cohort_start_year total_schools total_completed_mentors] => :environment do |_t, args|
    return unless Rails.env.in?(%w[development review sandbox])

    lead_provider = LeadProvider.find_by(name: args[:lead_provider_name])
    raise "LeadProvider not found: #{args[:lead_provider_name]}" if args[:lead_provider_name] && !lead_provider

    cohort = Cohort.find_by(start_year: args[:cohort_start_year])
    raise "Cohort not found: #{args[:cohort_start_year]}" if args[:cohort_start_year] && !cohort

    Array.wrap(lead_provider || LeadProvider.name_order.joins(:cohorts).includes(:cohorts)).each do |lp|
      Array.wrap(cohort || Cohort.between_years((Date.current - 2.years + 1.day).year, (Date.current + 1.year).year)).each do |c|
        ValidTestDataGenerators::ECFLeadProviderPopulater.call(name: lp.name, cohort: c, total_schools: args[:total_schools]&.to_i || 5, participants_per_school: 50)
        ValidTestDataGenerators::CompletedMentorGenerator.call(name: lp.name, cohort: c, total_completed_mentors: args[:total_completed_mentors]&.to_i || 30)
        ValidTestDataGenerators::SandboxSharedData.new(name: lp.name, cohort: c).call
      end
    end
  end
end
