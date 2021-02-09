# frozen_string_literal: true

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end

if Rails.env.development? || Rails.env.deployed_development?
  if AdminProfile.none?
    user = User.find_or_create_by!(email: "admin@example.com") do |u|
      u.full_name = "Admin User"
      u.confirmed_at = Time.zone.now.utc
    end
    AdminProfile.create!(user: user)
  end

  if InductionCoordinatorProfile.none?
    user = User.find_or_create_by!(email: "school-leader@example.com") do |u|
      u.full_name = "School Leader User"
      u.confirmed_at = Time.zone.now.utc
    end
    InductionCoordinatorProfile.create!(user: user)
  end

  if EarlyCareerTeacherProfile.none?
    user = User.find_or_create_by!(email: "early-career-teacher@example.com") do |u|
      u.full_name = "ECT User"
      u.confirmed_at = Time.zone.now.utc
    end
    EarlyCareerTeacherProfile.create!(user: user, cohort: Cohort.first, core_induction_programme: CoreInductionProgramme.first)
  end
end
