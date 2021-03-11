# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

if Cohort.none?
  Cohort.find_or_create_by!(start_year: 2021)
  Cohort.find_or_create_by!(start_year: 2022)
end

# TODO: Remove this when we have a way of adding lead providers, or expand to include all of them
unless LeadProvider.first
  LeadProvider.find_or_create_by!(name: "Test Lead Provider")
end

test_lead_provider = LeadProvider.find_by(name: "Test Lead Provider")

if test_lead_provider
  test_lead_provider.cohorts = Cohort.all
  test_lead_provider.save!
end

if CoreInductionProgramme.none?
  CoreInductionProgramme.find_or_create_by!(name: "Ambition Institute")
  CoreInductionProgramme.find_or_create_by!(name: "Education Development Trust")
  CoreInductionProgramme.find_or_create_by!(name: "Teach First")
  CoreInductionProgramme.find_or_create_by!(name: "UCL")
end

if Rails.env.development? || Rails.env.deployed_development?
  User.undiscard_all!
  AdminProfile.undiscard_all!
  InductionCoordinatorProfile.undiscard_all!
  LeadProviderProfile.undiscard_all!

  user = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.full_name = "Admin User"
    u.confirmed_at = Time.zone.now.utc
  end
  AdminProfile.find_or_create_by!(user: user)

  (1..5).each do |number|
    user = User.find_or_create_by!(email: "second-admin-#{number}@example.com") do |u|
      u.full_name = "Second Admin User #{number}"
      u.confirmed_at = Time.zone.now.utc
    end
    AdminProfile.find_or_create_by!(user: user)

    user = User.find_or_create_by!(email: "second-lead-provider-#{number}@example.com") do |u|
      u.full_name = "Second Lp User #{number}"
      u.confirmed_at = Time.zone.now.utc
    end
    LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)

    user = User.find_or_create_by!(email: "second-school-leader-#{number}@example.com") do |u|
      u.full_name = "School Leader User - Induction Coordinator #{number}"
      u.confirmed_at = Time.zone.now.utc
    end
    if School.any?
      InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first])
    end
  end

  user = User.find_or_create_by!(email: "lead-provider@example.com") do |u|
    u.full_name = "Lp User"
    u.confirmed_at = Time.zone.now.utc
  end
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)

  school_urns_twenty_twenty_one = %w[136089 105448 128702 113280 138229 143094 140667 127834 146786 113199 126346 133936 132971 107126 102887 102418 129369 140980 116848 112236]

  School.where(urn: school_urns_twenty_twenty_one).each do |school|
    Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2021))
  end

  school_urns_twenty_twenty_two = %w[119378 134847 113870 127979 144744 121499 147505 105626 402027 100173]

  School.where(urn: school_urns_twenty_twenty_two).each do |school|
    Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_or_create_by!(start_year: 2022))
  end

  user = User.find_or_create_by!(email: "second-school-leader@example.com") do |u|
    u.full_name = "School Leader User - Induction Coordinator"
    u.confirmed_at = Time.zone.now.utc
  end
  if School.any?
    InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first])
  end

  user = User.find_or_create_by!(email: "school-leader@example.com") do |u|
    u.full_name = "School Leader User"
    u.confirmed_at = Time.zone.now.utc
  end
  if School.any?
    InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first])
  end

  user = User.find_or_create_by!(email: "early-career-teacher@example.com") do |u|
    u.full_name = "ECT User"
    u.confirmed_at = Time.zone.now.utc
  end
  if School.any?
    EarlyCareerTeacherProfile.find_or_create_by!(user: user, school: School.first, cohort: Cohort.first, core_induction_programme: CoreInductionProgramme.first)
  end
end
