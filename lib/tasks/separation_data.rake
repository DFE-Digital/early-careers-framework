# frozen_string_literal: true

namespace :lead_providers do
  desc "seed good test data for lead providers for API testing"
  task :seed_statements_and_applications, %i[lead_provider_name participants_per_school cohort_start_year total_schools] => :environment do |_t, args|
    return unless Rails.env.in?(%w[development review separation])

    lead_provider = LeadProvider.find_by(name: args[:lead_provider_name])
    raise "LeadProvider not found: #{args[:lead_provider_name]}" if args[:lead_provider_name] && !lead_provider

    cohort = Cohort.find_by(start_year: args[:cohort_start_year])
    raise "Cohort not found: #{args[:cohort_start_year]}" if args[:cohort_start_year] && !cohort

    Array.wrap(lead_provider || LeadProvider.name_order.joins(:cohorts).includes(:cohorts)).each do |lp|
      Array.wrap(cohort || Cohort.between_years((Date.current - 2.years + 1.day).year, (Date.current + 1.year).year)).each do |c|
        ValidTestDataGenerator::LeadProviderPopulater.call(name: lp.name, cohort: c, total_schools:  args[:total_schools]&.to_i || 5, participants_per_school: 50)
      end
    end
  end
end
