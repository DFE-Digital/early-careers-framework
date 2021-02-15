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

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end

if CoreInductionProgramme.none?
  CoreInductionProgramme.create!(name: "Ambition Institute")
  CoreInductionProgramme.create!(name: "Education Development Trust")
  CoreInductionProgramme.create!(name: "Teach First")
  CoreInductionProgramme.create!(name: "UCL")
end

if Rails.env.development? || Rails.env.deployed_development?
  if AdminProfile.none?
    user = User.find_or_create_by!(email: "admin@example.com") do |u|
      u.full_name = "Admin User"
      u.confirmed_at = Time.zone.now.utc
    end
    AdminProfile.create!(user: user)
  end

  if LeadProviderProfile.none?
    user = User.find_or_create_by!(email: "lead-provider@example.com") do |u|
      u.full_name = "Lp User"
      u.confirmed_at = Time.zone.now.utc
    end
    LeadProviderProfile.create!(user: user, lead_provider: LeadProvider.first)
  end

  if InductionCoordinatorProfile.none?
    user = User.find_or_create_by!(email: "school-leader@example.com") do |u|
      u.full_name = "School Leader User"
      u.confirmed_at = Time.zone.now.utc
    end
    InductionCoordinatorProfile.create!(user: user, schools: [School.first])
  end

  if EarlyCareerTeacherProfile.none?
    user = User.find_or_create_by!(email: "early-career-teacher@example.com") do |u|
      u.full_name = "ECT User"
      u.confirmed_at = Time.zone.now.utc
    end
    EarlyCareerTeacherProfile.create!(user: user, school: School.first, cohort: Cohort.first, core_induction_programme: CoreInductionProgramme.first)
  end
end
