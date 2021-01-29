# frozen_string_literal: true

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
  AdminProfile.create!(user: user)
end

unless CoreInductionProgramme.first
  CoreInductionProgramme.create!(name: "Ambition Institute")
  CoreInductionProgramme.create!(name: "Education Development Trust")
  CoreInductionProgramme.create!(name: "Teach First")
  CoreInductionProgramme.create!(name: "UCL")
end

unless Cohort.first
  Cohort.create!(start_year: 2021)
  Cohort.create!(start_year: 2022)
end
