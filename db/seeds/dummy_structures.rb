# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

User.find_or_create_by!(email: "admin@example.com") do |user|
  user.update!(full_name: "Admin User")
  AdminProfile.find_or_create_by!(user: user)
end

User.find_or_create_by!(email: "lead-provider@example.com") do |user|
  user.update!(full_name: "LeadProvider User")
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)
end

school = School.find_or_create_by!(
  name: "Example school",
  postcode: "BB1 1BB",
  address_line1: "3 Madeup Street",
  primary_contact_email: "school-info@example.com",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "E123",
  urn: "999999",
)

SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "core_induction_programme")

school_two = School.find_or_create_by!(
  name: "Example school two",
  postcode: "ZZ1 1ZZ",
  address_line1: "99 Madeup Road",
  primary_contact_email: "school-2-info@example.com",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "WA4 1AA",
  urn: "111111",
)

SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_two, induction_programme_choice: "core_induction_programme")

school_three = School.find_or_create_by!(
  name: "Example school three",
  postcode: "WA1 1AA",
  address_line1: "100 Warrington Road",
  primary_contact_email: "school-3-info@example.com",
  school_status_code: 1,
  school_type_code: 1,
  administrative_district_code: "W123",
  urn: "5555555",
)

SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_three, induction_programme_choice: "full_induction_programme")

User.find_or_create_by!(email: "school-leader@example.com") do |user|
  user.update!(full_name: "InductionTutor User")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
end

mentor = User.find_or_create_by!(email: "rp-mentor-ambition@example.com") do |user|
  user.update!(full_name: "Sally Mentor")
  MentorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "Ambition Institute"))
  end
end

mentor_two = User.find_or_create_by!(email: "rp-mentor-edt@example.com") do |user|
  user.update!(full_name: "Jane Doe")
  MentorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school_two, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "Education Development Trust"))
  end
end

mentor_three = User.find_or_create_by!(email: "rp-mentor-ucl@example.com") do |user|
  user.update!(full_name: "Abdul Mentor")
  MentorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school_three, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "UCL Institute of Education"))
  end
end

User.find_or_create_by!(email: "rp-ect-ambition@example.com") do |user|
  user.update!(full_name: "Joe Bloggs")
  EarlyCareerTeacherProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "Ambition Institute"), mentor_profile: mentor.mentor_profile)
  end
end

User.find_or_create_by!(email: "rp-ect-edt@example.com") do |user|
  user.update!(full_name: "John Doe")
  EarlyCareerTeacherProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school_two, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "Education Development Trust"), mentor_profile: mentor_two.mentor_profile)
  end
end

User.find_or_create_by!(email: "rp-ect-ucl@example.com") do |user|
  user.update!(full_name: "Dan Smith")
  EarlyCareerTeacherProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(school: school_three, cohort: Cohort.current, core_induction_programme: CoreInductionProgramme.find_by(name: "UCL Institute of Education"), mentor_profile: mentor_three.mentor_profile)
  end
end

# We clear the database on a regular basis, but we want a stable token that E&L can use in its dev environments
# Hashed token with the same unhashed version will be different between dev and deployed dev
# The tokens below have different unhashed version to avoid worrying about clever cryptographic attacks
if Rails.env.deployed_development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "dfce9a34c6f982e8adb4b903f8b6064682e6ad1f7858c41ed8a0a7468abc8896")
  NpqRegistrationApiToken.find_or_create_by!(hashed_token: "1dae3836ed90df4b796eff1f4a4713247ac5bc8a00352ea46eee621d74cd4fcf")
elsif Rails.env.development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
end
