# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

if Cohort.none?
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
  user = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.full_name = "Admin User"
    u.confirmed_at = Time.zone.now.utc
  end
  AdminProfile.find_or_create_by!(user: user)

  user = User.find_or_create_by!(email: "lead-provider@example.com") do |u|
    u.full_name = "Lp User"
    u.confirmed_at = Time.zone.now.utc
  end
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)

  school_urns_twenty_twenty_one = %w[136089 105448 128702 113280 138229 143094 140667 127834 146786 113199 126346 133936 132971 107126 102887 102418 129369 140980 116848 112236]

  School.where(urn: school_urns_twenty_twenty_one).each do |school|
    Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_by(start_year: 2021))
  end

  school_urns_twenty_twenty_two = %w[119378 134847 113870 127979 144744 121499 147505 105626 402027 100173]

  School.where(urn: school_urns_twenty_twenty_two).each do |school|
    Partnership.find_or_create_by!(school: school, lead_provider: LeadProvider.first, cohort: Cohort.find_by(start_year: 2022))
  end

  user = User.find_or_create_by!(email: "school-leader@example.com") do |u|
    u.full_name = "School Leader User"
    u.confirmed_at = Time.zone.now.utc
  end
  InductionCoordinatorProfile.joins(:schools).find_or_create_by!(user: user, schools: [School.first])

  user = User.find_or_create_by!(email: "early-career-teacher@example.com") do |u|
    u.full_name = "ECT User"
    u.confirmed_at = Time.zone.now.utc
  end
  EarlyCareerTeacherProfile.find_or_create_by!(user: user, school: School.first, cohort: Cohort.first, core_induction_programme: CoreInductionProgramme.first)
end
