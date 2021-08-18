# frozen_string_literal: true

DOMAIN = "@digital.education.gov.uk" # Prevent low effort email scraping
cohort_2022 = Cohort.find_or_create_by!(start_year: 2022)

local_authority = LocalAuthority.find_or_create_by!(name: "ZZ Test Local Authority", code: "ZZTEST")

School.find_or_create_by!(urn: "000001") do |school|
  school.update!(
    name: "ZZ Test School 1",
    postcode: "AA1 1AA",
    address_line1: "1 Nowhere lane",
    primary_contact_email: "cpd-test+school-1#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(urn: "000002") do |school|
  school.update!(
    name: "ZZ Test School 2",
    postcode: "AA2 2AA",
    address_line1: "2 Nowhere lane",
    primary_contact_email: "",
    secondary_contact_email: "cpd-test+school-2#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
end

School.find_or_create_by!(urn: "000003") do |school|
  school.update!(
    name: "ZZ Test School 3",
    postcode: "AA3 3AA",
    address_line1: "3 Nowhere lane",
    primary_contact_email: "cpd-test+school-3#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  NominationEmail.find_or_create_by!(
    token: "abc123",
    sent_to: "cpd-test+school-3#{DOMAIN}",
    sent_at: 1.year.ago,
    school: school,
  )
end

School.find_or_create_by!(urn: "000004") do |school|
  school.update!(
    name: "ZZ Test School 4",
    postcode: "AA4 4AA",
    address_line1: "4 Nowhere lane",
    primary_contact_email: "cpd-test+school-4#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 4", email: "cpd-test+tutor-1#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  cip = CoreInductionProgramme.first
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
end

School.find_or_create_by!(urn: "000005") do |school|
  school.update!(
    name: "ZZ Test School 5",
    postcode: "AA4 4AA",
    address_line1: "4 Nowhere lane",
    primary_contact_email: "cpd-test+school-5#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E123",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 5", email: "cpd-test+tutor-2#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.first, challenge_deadline: 2.weeks.from_now)
  PartnershipNotificationEmail.find_or_create_by!(
    partnership: partnership,
    sent_to: "cpd-test+tutor-2#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc123",
  )
end

30.times do |idx|
  urn = (100 + idx).to_s.rjust(6, "0")
  item_num = 7 + idx
  School.find_or_create_by!(urn: urn) do |school|
    school.update!(
      name: "ZZ Test School #{item_num}",
      postcode: "AX4 9AB",
      address_line1: "#{item_num} School Lane",
      primary_contact_email: "cpd-test+school-#{item_num}#{DOMAIN}",
      school_status_code: 1,
      school_type_code: 1,
      administrative_district_code: "E#{900 + idx}",
    )
    SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
    user = User.find_or_create_by!(full_name: "Induction Tutor for School #{item_num}", email: "cpd-test+tutor-#{item_num}@example.com")
    InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
      profile.schools << school
    end

    SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
    delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
    partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.first, challenge_deadline: 2.weeks.from_now)
    PartnershipNotificationEmail.find_or_create_by!(
      partnership: partnership,
      sent_to: "cpd-test+tutor-3#{DOMAIN}",
      email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
      token: "abc424#{item_num}",
    )

    if idx.even?
      cip = CoreInductionProgramme.all.sample
      SchoolCohort.find_or_create_by!(cohort: cohort_2022, school: school, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
    end
  end
end

School.find_or_create_by!(urn: "000006") do |school|
  school.update!(
    name: "ZZ Test School 6",
    postcode: "AX4 9AB",
    address_line1: "27 School Lane",
    primary_contact_email: "cpd-test+school-6#{DOMAIN}",
    school_status_code: 1,
    school_type_code: 1,
    administrative_district_code: "E901",
  )
  SchoolLocalAuthority.find_or_create_by!(school: school, local_authority: local_authority, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 6", email: "cpd-test+tutor-3#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
    profile.update!(schools: [school])
  end
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner: delivery_partner, school: school, lead_provider: LeadProvider.first)
  PartnershipNotificationEmail.find_or_create_by!(
    partnership: partnership,
    sent_to: "cpd-test+tutor-3#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc424",
  )
  PupilPremium.find_or_create_by!(school: school, start_year: 2021, total_pupils: 500, eligible_pupils: 300)
end

delivery_partner = DeliveryPartner.find_or_create_by!(name: "Amazing Delivery Partner")

ProviderRelationship.find_or_create_by!(
  lead_provider: LeadProvider.first,
  delivery_partner: delivery_partner,
  cohort: Cohort.current,
)

example_contract_data = {
  "uplift_target": 0.33,
  "uplift_amount": 100,
  "recruitment_target": 2000,
  "set_up_fee": 149_861,
  "band_a": {
    "max": 2000,
    "per_participant": 995,
  },
  "band_b": {
    "min": 2001,
    "max": 4000,
    "per_participant": 979,
  },
  "band_c": {
    "min": 4001,
    "per_participant": 966,
  },
}

LeadProvider.all.each do |lp|
  sample_call_off_contract = CallOffContract.find_or_create_by!(
    lead_provider: lp,
    version: example_contract_data[:version] || "0.0.1",
    uplift_target: example_contract_data[:uplift_target],
    uplift_amount: example_contract_data[:uplift_amount],
    recruitment_target: example_contract_data[:recruitment_target],
    set_up_fee: example_contract_data[:set_up_fee],
    raw: example_contract_data.to_json,
  )

  %i[band_a band_b band_c].each do |band|
    src = example_contract_data[band]
    ParticipantBand.find_or_create_by!(
      call_off_contract: sample_call_off_contract,
      min: src[:min],
      max: src[:max],
      per_participant: src[:per_participant],
    )
  end
end

# FIP ECT
user = User.find_or_create_by!(email: "fip-ect@example.com") do |u|
  u.full_name = "FIP ECT"
end

teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000103").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule.default
end

# FIP mentor
user = User.find_or_create_by!(email: "fip-mentor@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000104").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# FIP mentor already doing an NPQ with the same email
user = User.find_or_create_by!(email: "fip-mentor-npq@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "1958553"
end
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end
ParticipantProfile::NPQ.find_or_create_by!(teacher_profile: teacher_profile, schedule: Finance::Schedule.default)

# FIP mentor already doing an NPQ with a different email
user = User.find_or_create_by!(email: "fip-mentor-npq-other-email@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "2369848"
end
ParticipantProfile::NPQ.find_or_create_by!(teacher_profile: teacher_profile, schedule: Finance::Schedule.default)

user = User.find_or_create_by!(email: "fip-mentor2@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# FIP mentor already mentoring at another school with another email
user = User.find_or_create_by!(email: "fip-mentor-another-school@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "1357010"
end
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "fip-mentor3@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000106").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# SIT also a mentor
user = User.find_by(email: "cpd-test+tutor-17@example.com")
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = user.induction_coordinator_profile.schools.first.school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# Extra participant records
user = User.find_or_create_by!(email: "fip-ect2@example.com") do |u|
  u.full_name = "FIP ECT"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000107").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "fip-mentor4@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000108").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "fip-mentor5@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000109").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end
# TODO: add validation data and eligibility records when merged

(200..210).each do |index|
  School.find_or_create_by!(urn: sprintf("%06d", index)) do |school|
    school.update!(
      name: "ZZ Test School #{index}",
      postcode: "AA4 4AA",
      address_line1: "4 Nowhere lane",
      school_status_code: 1,
      school_type_code: 1,
      administrative_district_code: "E123",
    )
    user = User.find_or_create_by!(full_name: "Induction Tutor for School #{index}", email: "cip-tutor-#{index}@example.com")
    InductionCoordinatorProfile.find_or_create_by!(user: user) do |profile|
      profile.schools << school
    end

    SchoolCohort.find_or_create_by!(cohort: Cohort.current, school: school, induction_programme_choice: "core_induction_programme")
  end
end

# CIP ECT
user = User.find_or_create_by!(email: "cip-ect@example.com") do |u|
  u.full_name = "CIP ECT"
end

teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000200").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule.default
end

# FIP mentor
user = User.find_or_create_by!(email: "cip-mentor@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000201").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# CIP mentor already doing an NPQ with the same email
user = User.find_or_create_by!(email: "cip-mentor-npq@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "1162128"
end
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000202").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end
ParticipantProfile::NPQ.find_or_create_by!(teacher_profile: teacher_profile, schedule: Finance::Schedule.default)

# CIP mentor already doing an NPQ with a different email
user = User.find_or_create_by!(email: "cip-mentor-npq-other-email@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "2631405"
end
ParticipantProfile::NPQ.find_or_create_by!(teacher_profile: teacher_profile, schedule: Finance::Schedule.default)

user = User.find_or_create_by!(email: "cip-mentor2@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000203").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# FIP mentor already mentoring at another school with another email
user = User.find_or_create_by!(email: "cip-mentor-another-school@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
  profile.trn = "1835206"
end
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000204").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "cip-mentor3@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000205").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# SIT also a mentor
user = User.find_by(email: "cip-tutor-206@example.com")
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = user.induction_coordinator_profile.schools.first.school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

# Extra participant records
user = User.find_or_create_by!(email: "cip-ect2@example.com") do |u|
  u.full_name = "CIP ECT"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile: teacher_profile) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000207").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "cip-mentor4@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000208").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end

user = User.find_or_create_by!(email: "cip-mentor5@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user: user)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile: teacher_profile) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000209").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule.default
end
