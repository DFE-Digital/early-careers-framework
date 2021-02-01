# frozen_string_literal: true

# TODO: Remove network and school seeding when we have a way of getting them from GIAS
unless Network.first
  network = Network.create!(name: "Test school network")
  School.create!(urn: "TEST_URN_1", name: "Test school one", address_line1: "Test address", country: "England", postcode: "TEST1", network: network, domains: %w[testschool1.sch.uk network.com digital.education.gov.uk])
  School.create!(urn: "TEST_URN_2", name: "Test school two", address_line1: "Test address London", country: "England", postcode: "TEST2", network: network, domains: %w[testschool2.sch.uk network.com digital.education.gov.uk])
  School.create!(urn: "TEST_URN_3", name: "Test school three", address_line1: "Test address Oxford", country: "England", postcode: "TEST3", domains: ["testschool3.sch.uk"])
  School.create!(urn: "TEST_URN_4", name: "Test school four", address_line1: "Test address Newcastle", country: "England", postcode: "TEST4", domains: ["testschool4.sch.uk"])
end

# TODO: Remove this when we have a way of adding lead providers, or expand to include all of them
unless LeadProvider.first
  LeadProvider.create!(name: "Test Lead Provider")
end

# TODO: Remove this when we have a way of adding partnerships
unless Partnership.first || Rails.env.production?
  Partnership.create!(school: School.first, lead_provider: LeadProvider.first)
end

if Rails.env.deployed_development? && User.none?
  user = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.full_name = "Admin User"
  end
  user.confirm
  AdminProfile.create!(user: user)

  user = User.find_or_create_by!(email: "lead-provider@example.com") do |u|
    u.full_name = "Lp User"
  end
  user.confirm
  LeadProviderProfile.create!(user: user, lead_provider: LeadProvider.first)

  user = User.find_or_create_by!(email: "school-leader@example.com") do |u|
    u.full_name = "School Leader User"
  end
  user.confirm
  InductionCoordinatorProfile.create!(user: user, schools: [School.first])
end

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end
