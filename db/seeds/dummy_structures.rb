# frozen_string_literal: true

# TODO: Remove network and school seeding when we have a way of getting them from GIAS
unless Network.first
  local_authority = LocalAuthority.create!(code: "TEST01", name: "Test local authority")
  local_authority_district = LocalAuthorityDistrict.create!(code: "TEST01", name: "Test local authority")
  network = Network.create!(name: "Test school network")
  School.create!(urn: "TEST_URN_1", name: "Test school one", address_line1: "Test address", country: "England", postcode: "TEST1", network: network, domains: %w[testschool1.sch.uk network.com digital.education.gov.uk], local_authority: local_authority, local_authority_district: local_authority_district)
  School.create!(urn: "TEST_URN_2", name: "Test school two", address_line1: "Test address London", country: "England", postcode: "TEST2", network: network, domains: %w[testschool2.sch.uk network.com digital.education.gov.uk], local_authority: local_authority, local_authority_district: local_authority_district)
end

# TODO: Remove this when we have a way of adding lead providers, or expand to include all of them
unless LeadProvider.first
  LeadProvider.create!(name: "Test Lead Provider")
end

# TODO: Remove this when we have a way of adding partnerships
unless Partnership.first || Rails.env.production?
  Partnership.create!(school: School.first, lead_provider: LeadProvider.first)
end

unless AdminProfile.first || Rails.env.production?
  user = User.find_or_create_by!(email: "ecf@mailinator.com") do |u|
    u.full_name = "Admin User"
  end
  user.confirm
  AdminProfile.create!(user: user)
end

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end
