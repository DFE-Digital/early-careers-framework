# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

User.find_or_create_by!(email: "admin@example.com") do |user|
  user.update!(full_name: "Admin User")
  AdminProfile.find_or_create_by!(user: user)
end

User.find_or_create_by!(email: "finance@example.com") do |user|
  user.update!(full_name: "Finance User")
  FinanceProfile.find_or_create_by!(user: user)
end

User.find_or_create_by!(email: "lead-provider@example.com") do |user|
  user.update!(full_name: "LeadProvider User")
  LeadProviderProfile.find_or_create_by!(user: user, lead_provider: LeadProvider.first)
end

school = School.find_or_create_by!(urn: "999999") do |created_school|
  created_school.name = "Example school"
  created_school.postcode = "BB1 1BB"
  created_school.address_line1 = "3 Madeup Street"
  created_school.primary_contact_email = "school-info@example.com"
  created_school.school_status_code = 1
  created_school.school_type_code = 1
  created_school.administrative_district_code = "E123"
end

school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "core_induction_programme")

school_two = School.find_or_create_by!(urn: "111111") do |created_school|
  created_school.name = "Example school two"
  created_school.postcode = "ZZ1 1ZZ"
  created_school.address_line1 = "99 Madeup Road"
  created_school.primary_contact_email = "school-2-info@example.com"
  created_school.school_status_code = 1
  created_school.school_type_code = 1
  created_school.administrative_district_code = "WA4 1AA"
end

school_two_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_two, induction_programme_choice: "core_induction_programme")

school_three = School.find_or_create_by!(urn: "5555555") do |created_school|
  created_school.name = "Example school three"
  created_school.postcode = "WA1 1AA"
  created_school.address_line1 = "100 Warrington Road"
  created_school.primary_contact_email = "school-3-info@example.com"
  created_school.school_status_code = 1
  created_school.school_type_code = 1
  created_school.administrative_district_code = "W123"
end

school_three_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school_three, induction_programme_choice: "full_induction_programme")

User.find_or_create_by!(email: "school-leader@example.com") do |user|
  user.update!(full_name: "InductionTutor User")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
end

User.find_or_create_by!(email: "npq-registrant@example.com") do |user|
  user.update!(full_name: "NPQ registrant")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::NPQ.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

mentor = User.find_or_create_by!(email: "rp-mentor-ambition@example.com") do |user|
  user.update!(full_name: "Sally Mentor")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "Ambition Institute"), schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

mentor_two = User.find_or_create_by!(email: "rp-mentor-edt@example.com") do |user|
  user.update!(full_name: "Jane Doe")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_two_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "Education Development Trust"), schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

mentor_three = User.find_or_create_by!(email: "rp-mentor-ucl@example.com") do |user|
  user.update!(full_name: "Abdul Mentor")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_three_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "UCL Institute of Education"), schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

User.find_or_create_by!(email: "rp-ect-ambition@example.com") do |user|
  user.update!(full_name: "Joe Bloggs")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "Ambition Institute"), mentor_profile: mentor.mentor_profile, schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

User.find_or_create_by!(email: "rp-ect-edt@example.com") do |user|
  user.update!(full_name: "John Doe")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_two_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "Education Development Trust"), mentor_profile: mentor_two.mentor_profile, schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

User.find_or_create_by!(email: "rp-ect-ucl@example.com") do |user|
  user.update!(full_name: "Dan Smith")
  teacher_profile = user.teacher_profile || user.create_teacher_profile

  ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |profile|
    profile.update!(school_cohort: school_three_cohort, core_induction_programme: CoreInductionProgramme.find_by(name: "UCL Institute of Education"), mentor_profile: mentor_three.mentor_profile, schedule: Finance::Schedule.default)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
  end
end

# We clear the database on a regular basis, but we want a stable token that E&L can use in its dev environments
# Hashed token with the same unhashed version will be different between dev and deployed dev
# The tokens below have different unhashed version to avoid worrying about clever cryptographic attacks
if Rails.env.deployed_development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "dfce9a34c6f982e8adb4b903f8b6064682e6ad1f7858c41ed8a0a7468abc8896")
  NPQRegistrationApiToken.find_or_create_by!(hashed_token: "1dae3836ed90df4b796eff1f4a4713247ac5bc8a00352ea46eee621d74cd4fcf")
  DataStudioApiToken.find_or_create_by!(hashed_token: "c7123fb0e2aecb17e1089e01849d71665983e200e891fe726341a08f176c1d64")
elsif Rails.env.development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
end

if Rails.env.sandbox?
  NPQRegistrationApiToken.find_or_create_by!(hashed_token: "166eaa39950ad15f2f36041cb9062cc8fa9f109945fe9b8378bf904fe35369bc")
end

unless Rails.env.sandbox?
  [
    { name: "Ambition Institute", token: "ambition-token" },
    { name: "Best Practice Network", token: "best-practice-token" },
    { name: "Capita", token: "capita-token" },
    { name: "Education Development Trust", token: "edt-token" },
    { name: "Teach First", token: "teach-first-token" },
    { name: "UCL Institute of Education", token: "ucl-token" },
  ].each do |hash|
    cpd_lead_provider = CpdLeadProvider.find_by(name: hash[:name])
    LeadProviderApiToken.create_with_known_token!(hash[:token], cpd_lead_provider: cpd_lead_provider)
  end
end
