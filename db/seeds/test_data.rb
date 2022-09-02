# frozen_string_literal: true

require "tasks/valid_test_data_generator"
require_relative "call_off_contracts"
require "active_support/testing/time_helpers"

include ActiveSupport::Testing::TimeHelpers

DOMAIN = "@digital.education.gov.uk" # Prevent low effort email scraping
Cohort.find_or_create_by!(start_year: 2021)
cohort_2022 = Cohort.find_or_create_by!(start_year: 2022)
cohort_2023 = Cohort.find_or_create_by!(start_year: 2023)

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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
  NominationEmail.find_or_create_by!(
    token: "abc123",
    sent_to: "cpd-test+school-3#{DOMAIN}",
    sent_at: 1.year.ago,
    school:,
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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 4", email: "cpd-test+tutor-1#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
    profile.update!(schools: [school])
  end
  cip = CoreInductionProgramme.first
  SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
end

lead_provider = LeadProvider.find_by(name: "Ambition Institute")
lead_provider.users.create!(full_name: "Ambition User", email: "lead-provider-user@example.com")

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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 5", email: "cpd-test+tutor-2#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
    profile.update!(schools: [school])
  end
  school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Test Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner:, school:, lead_provider:, challenge_deadline: 2.weeks.from_now)
  InductionProgramme.find_or_create_by!(
    school_cohort:,
    partnership:,
    training_programme: "full_induction_programme",
  )
  PartnershipNotificationEmail.find_or_create_by!(
    partnership:,
    sent_to: "cpd-test+tutor-2#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc123",
  )
end

School.find_or_create_by!(urn: "181818") do |school|
  school.name = "ZZ TEST CIP only school"
  school.postcode = "XM4 5HQ"
  school.address_line1 = "North pole"
  school.primary_contact_email = "cip-only-school-info@example.com"
  school.school_status_code = 1
  school.school_type_code = 10

  user = User.find_or_create_by!(full_name: "Induction Tutor for CIP only school", email: "cip-only-induction-tutor@example.com")
  InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
    profile.update!(schools: [school])
  end
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
end

School.find_or_create_by!(urn: "181815") do |school|
  school.name = "ZZ TEST CIP only school 2"
  school.postcode = "XM4 5HQ"
  school.address_line1 = "South pole"
  school.primary_contact_email = "cip-only-school-info-2@example.com"
  school.school_status_code = 1
  school.school_type_code = 10
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
end

10.times do |idx|
  urn = (100 + idx).to_s.rjust(6, "0")
  item_num = 7 + idx
  School.find_or_create_by!(urn:) do |school|
    school.update!(
      name: "ZZ Test School #{item_num}",
      postcode: "AX4 9AB",
      address_line1: "#{item_num} School Lane",
      primary_contact_email: "cpd-test+school-#{item_num}#{DOMAIN}",
      school_status_code: 1,
      school_type_code: 1,
      administrative_district_code: "E#{900 + idx}",
    )
    SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
    user = User.find_or_create_by!(full_name: "Induction Tutor for School #{item_num}", email: "cpd-test+tutor-#{item_num}@example.com")
    InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
      profile.schools << school
    end

    school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "full_induction_programme")
    delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
    partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner:, school:, lead_provider:, challenge_deadline: 2.weeks.from_now)
    InductionProgramme.find_or_create_by!(
      school_cohort:,
      partnership:,
      training_programme: "full_induction_programme",
    )
    PartnershipNotificationEmail.find_or_create_by!(
      partnership:,
      sent_to: "cpd-test+tutor-3#{DOMAIN}",
      email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
      token: "abc424#{item_num}",
    )

    if idx.even?
      cip = CoreInductionProgramme.all.sample
      SchoolCohort.find_or_create_by!(cohort: cohort_2023, school:, induction_programme_choice: "core_induction_programme", core_induction_programme: cip)
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
  SchoolLocalAuthority.find_or_create_by!(school:, local_authority:, start_year: 2019)
  user = User.find_or_create_by!(full_name: "Induction Tutor for School 6", email: "cpd-test+tutor-3#{DOMAIN}")
  InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
    profile.update!(schools: [school])
  end
  school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "full_induction_programme")
  delivery_partner = DeliveryPartner.find_or_create_by!(name: "Mega Delivery Partner")
  partnership = Partnership.find_or_create_by!(cohort: Cohort.current, delivery_partner:, school:, lead_provider:)
  InductionProgramme.find_or_create_by!(
    school_cohort:,
    partnership:,
    training_programme: "full_induction_programme",
  )
  PartnershipNotificationEmail.find_or_create_by!(
    partnership:,
    sent_to: "cpd-test+tutor-3#{DOMAIN}",
    email_type: PartnershipNotificationEmail.email_types[:induction_coordinator_email],
    token: "abc424",
  )
  PupilPremium.find_or_create_by!(school:, start_year: 2022, total_pupils: 500, eligible_pupils: 300)
end

delivery_partner = DeliveryPartner.find_or_create_by!(name: "Amazing Delivery Partner")

ProviderRelationship.find_or_create_by!(
  lead_provider:,
  delivery_partner:,
  cohort: Cohort.current,
)

Seeds::CallOffContracts.new.call

npq_specifics = [
  {
    version: "0.0.1",
    recruitment_target: 300,
    course_identifier: "npq-additional-support-offer",
    number_of_payment_periods: 4,
    per_participant: 800.00,
    service_fee_percentage: 0,
    output_payment_percentage: 100,
    service_fee_installments: 18,
  },
  {
    version: "0.0.1",
    recruitment_target: 1000,
    course_identifier: "npq-leading-teaching",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.1",
    recruitment_target: 1000,
    course_identifier: "npq-leading-behaviour-culture",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.1",
    recruitment_target: 1500,
    course_identifier: "npq-leading-teaching-development",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.1",
    recruitment_target: 2000,
    course_identifier: "npq-senior-leadership",
    number_of_payment_periods: 4,
    per_participant: 1149.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 24,
  },
  {
    version: "0.0.1",
    recruitment_target: 1000,
    course_identifier: "npq-headship",
    number_of_payment_periods: 4,
    per_participant: 1985.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 30,
  },
  {
    version: "0.0.1",
    recruitment_target: 400,
    course_identifier: "npq-executive-leadership",
    number_of_payment_periods: 4,
    per_participant: 4099.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 24,
  },

  # Version 0.0.2
  {
    version: "0.0.2",
    recruitment_target: 100,
    course_identifier: "npq-additional-support-offer",
    number_of_payment_periods: 4,
    per_participant: 800.00,
    service_fee_percentage: 0,
    output_payment_percentage: 100,
    service_fee_installments: 18,
  },
  {
    version: "0.0.2",
    recruitment_target: 1500,
    course_identifier: "npq-leading-teaching",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.2",
    recruitment_target: 750,
    course_identifier: "npq-leading-behaviour-culture",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.2",
    recruitment_target: 1500,
    course_identifier: "npq-leading-teaching-development",
    number_of_payment_periods: 3,
    per_participant: 902.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 18,
  },
  {
    version: "0.0.2",
    recruitment_target: 1250,
    course_identifier: "npq-senior-leadership",
    number_of_payment_periods: 4,
    per_participant: 1149.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 24,
  },
  {
    version: "0.0.2",
    recruitment_target: 750,
    course_identifier: "npq-headship",
    number_of_payment_periods: 4,
    per_participant: 1985.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 30,
  },
  {
    version: "0.0.2",
    recruitment_target: 100,
    course_identifier: "npq-executive-leadership",
    number_of_payment_periods: 4,
    per_participant: 4099.00,
    service_fee_percentage: 40,
    output_payment_percentage: 60,
    service_fee_installments: 24,
  },
]

# NPQ contracts
NPQLeadProvider.all.each do |npq_lead_provider|
  npq_specifics.each do |npq_contract|
    attributes = npq_contract.merge(npq_lead_provider:, cohort: cohort_2022)
    attributes.merge!(raw: attributes.to_json)
    NPQContract.create!(attributes)
  end
end

# FIP ECT
user = User.find_or_create_by!(email: "fip-ect@example.com") do |u|
  u.full_name = "FIP ECT"
end

teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000103").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

user = User.find_or_create_by!(email: "withdrawn-fip-ect@example.com") do |u|
  u.full_name = "WITHDRAWN FIP ECT"
end

teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000103").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ect_profile.training_status_withdrawn!
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# FIP mentor
user = User.find_or_create_by!(email: "fip-mentor@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000104").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# FIP mentor already doing an NPQ with the same email
user = User.find_or_create_by!(email: "fip-mentor-npq@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:) do |profile|
  profile.trn = "1958553"
end
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

npq_profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |profile|
  profile.schedule = Finance::Schedule::NPQSpecialist.default
  profile.participant_identity = Identity::Create.call(user:, origin: :npq)
end
ParticipantProfileState.find_or_create_by!({ participant_profile: npq_profile })

# FIP mentor already doing an NPQ with a different email
user = User.find_or_create_by!(email: "fip-mentor-npq-other-email@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end

teacher_profile = TeacherProfile.find_or_create_by!(user:) do |profile|
  profile.trn = "2369848"
end

npq_profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |profile|
  profile.schedule = Finance::Schedule::NPQSpecialist.default
  profile.participant_identity = Identity::Create.call(user:, origin: :npq)
end
ParticipantProfileState.find_or_create_by!({ participant_profile: npq_profile })

user = User.find_or_create_by!(email: "fip-mentor2@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# FIP mentor already mentoring at another school with another email
user = User.find_or_create_by!(email: "fip-mentor-another-school@example.com") do |u|
  u.full_name = "FIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:) do |profile|
  profile.trn = "1357010"
end
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000105").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

user = User.find_or_create_by!(email: "fip-mentor3@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000106").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# SIT also a mentor
user = User.find_by(email: "cpd-test+tutor-7@example.com")
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = user.induction_coordinator_profile.schools.first.school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# Extra participant records
user = User.find_or_create_by!(email: "fip-ect2@example.com") do |u|
  u.full_name = "FIP ECT"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000107").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
end

user = User.find_or_create_by!(email: "fip-ect3@example.com") do |u|
  u.full_name = "FIP ECT"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000108").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
end
induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

user = User.find_or_create_by!(email: "fip-mentor4@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000108").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

user = User.find_or_create_by!(email: "fip-mentor5@example.com") do |u|
  u.full_name = "FIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000109").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

# TODO: add validation data and eligibility records when merged

(200..206).each do |index|
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
    InductionCoordinatorProfile.find_or_create_by!(user:) do |profile|
      profile.schools << school
    end

    delivery_partner = lead_provider.delivery_partners.first
    school_cohort = SchoolCohort.find_or_create_by!(cohort: Cohort.current, school:, induction_programme_choice: "core_induction_programme")
    partnership = Partnership.find_or_create_by!(cohort: school_cohort.cohort, school:, lead_provider:, delivery_partner:)

    InductionProgramme.find_or_create_by!(
      school_cohort:,
      partnership:,
      training_programme: "full_induction_programme",
    )
  end
end

# CIP ECT
user = User.find_or_create_by!(email: "cip-ect@example.com") do |u|
  u.full_name = "CIP ECT"
end

teacher_profile = TeacherProfile.find_or_create_by!(user:)
profile = ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000200").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
end
Induction::Enrol.call(participant_profile: profile, induction_programme: profile.school_cohort.induction_programmes.first)

# CIP mentor
user = User.find_or_create_by!(email: "cip-mentor@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000201").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end
Induction::Enrol.call(participant_profile: profile, induction_programme: profile.school_cohort.induction_programmes.first)

# CIP mentor already doing an NPQ with the same email
user = User.find_or_create_by!(email: "cip-mentor-npq@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:) do |p|
  p.trn = "1162128"
end
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000202").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
  Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: mentor_profile.school_cohort.induction_programmes.first)
end
npq_profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |p|
  p.schedule = Finance::Schedule::NPQSpecialist.default
  p.participant_identity = Identity::Create.call(user:, origin: :npq)
end
ParticipantProfileState.find_or_create_by!({ participant_profile: npq_profile })

# CIP mentor already doing an NPQ with a different email
user = User.find_or_create_by!(email: "cip-mentor-npq-other-email@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:) do |p|
  p.trn = "2631405"
end
npq_profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |p|
  p.schedule = Finance::Schedule::NPQSpecialist.default
  p.participant_identity = Identity::Create.call(user:, origin: :npq)
end
ParticipantProfileState.find_or_create_by!({ participant_profile: npq_profile })

user = User.find_or_create_by!(email: "cip-mentor2@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000203").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
  Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: mentor_profile.school_cohort.induction_programmes.first)
end

# FIP mentor already mentoring at another school with another email
user = User.find_or_create_by!(email: "cip-mentor-another-school@example.com") do |u|
  u.full_name = "CIP Mentor NPQ"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:) do |p|
  p.trn = "1835206"
end
participant_profile = ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000204").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
end

induction_programme = participant_profile.school_cohort.induction_programmes.first
raise unless induction_programme

Induction::Enrol.call(participant_profile:, induction_programme:)

user = User.find_or_create_by!(email: "cip-mentor3@example.com") do |u|
  u.full_name = "CIP Mentor"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = School.find_by(urn: "000205").school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
  Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: mentor_profile.school_cohort.induction_programmes.first)
end

# SIT also a mentor
user = User.find_by(email: "cip-tutor-201@example.com")
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::Mentor.find_or_create_by!(teacher_profile:) do |mentor_profile|
  mentor_profile.school_cohort = user.induction_coordinator_profile.schools.first.school_cohorts.find_by(cohort: Cohort.current)
  mentor_profile.schedule = Finance::Schedule::ECF.default
  mentor_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: mentor_profile)
  Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: mentor_profile.school_cohort.induction_programmes.first)
end

# Extra participant records
user = User.find_or_create_by!(email: "cip-ect2@example.com") do |u|
  u.full_name = "CIP ECT"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |ect_profile|
  ect_profile.school_cohort = School.find_by(urn: "000206").school_cohorts.find_by(cohort: Cohort.current)
  ect_profile.schedule = Finance::Schedule::ECF.default
  ect_profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: ect_profile)
  Induction::Enrol.call(participant_profile: ect_profile, induction_programme: ect_profile.school_cohort.induction_programmes.first)
end

def create_fip_ect_with_eligibility(type, *args)
  name = "FIP ECT #{type}"
  create_participant_with_eligibility("000103", name, ParticipantProfile::ECT, *args)
end

def create_fip_mentor_with_eligibility(type, *args)
  name = "FIP Mentor #{type}"
  create_participant_with_eligibility("000103", name, ParticipantProfile::Mentor, *args)
end

def create_cip_ect_with_eligibility(type, *args)
  name = "CIP ECT #{type}"
  create_participant_with_eligibility("000200", name, ParticipantProfile::ECT, *args)
end

def create_cip_mentor_with_eligibility(type, *args)
  name = "CIP Mentor #{type}"
  create_participant_with_eligibility("000200", name, ParticipantProfile::Mentor, *args)
end

def create_participant_with_eligibility(urn, name, participant_class, options = {})
  user = User.find_or_create_by!(email: "#{name.parameterize}@example.com") do |u|
    u.full_name = name
  end

  teacher_profile = TeacherProfile.find_or_create_by!(user:)
  participant_class.find_or_create_by!(teacher_profile:) do |profile|
    profile.school_cohort = School.find_by(urn:).school_cohorts.find_by(cohort: Cohort.current)
    profile.schedule = Finance::Schedule::ECF.default
    profile.participant_identity = Identity::Create.call(user:, origin: :ecf)
    ParticipantProfileState.find_or_create_by!(participant_profile: profile)
    ECFParticipantValidationData.find_or_create_by!(participant_profile: profile)
    default_options = {
      participant_profile: profile,
      qts: true,
      previous_participation: false,
      previous_induction: false,
      active_flags: false,
      different_trn: false,
    }

    ECFParticipantEligibility.find_or_create_by!(default_options.merge(options))
    Induction::Enrol.call(participant_profile: profile, induction_programme: profile.school_cohort.induction_programmes.first)
  end
end

user = User.find_or_create_by!(email: "cip-ect-email-sent@example.com") do |u|
  u.full_name = "CIP ECT Email Sent"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |p|
  p.request_for_details_sent_at = Time.zone.now
  p.school_cohort = School.find_by(urn: "000200").school_cohorts.find_by(cohort: Cohort.current)
  p.schedule = Finance::Schedule::ECF.default
  p.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: p)
  Email.create!(tags: [:request_for_details], status: "delivered").create_association_with(p)
  Induction::Enrol.call(participant_profile: p, induction_programme: p.school_cohort.induction_programmes.first)
end

user = User.find_or_create_by!(email: "cip-ect-email-bounced@example.com") do |u|
  u.full_name = "CIP ECT Email bounced"
end
teacher_profile = TeacherProfile.find_or_create_by!(user:)
ParticipantProfile::ECT.find_or_create_by!(teacher_profile:) do |p|
  p.request_for_details_sent_at = Time.zone.now
  p.school_cohort = School.find_by(urn: "000200").school_cohorts.find_by(cohort: Cohort.current)
  p.schedule = Finance::Schedule::ECF.default
  p.participant_identity = Identity::Create.call(user:, origin: :ecf)
  ParticipantProfileState.find_or_create_by!(participant_profile: p)
  Email.create!(tags: [:request_for_details], status: "permanent-failure").create_association_with(p)
  Induction::Enrol.call(participant_profile: p, induction_programme: p.school_cohort.induction_programmes.first)
end

create_fip_ect_with_eligibility("Eligible")
create_fip_ect_with_eligibility("Previous Induction", { previous_induction: true })
create_fip_ect_with_eligibility("No QTS", { qts: false })
create_fip_ect_with_eligibility("Different TRN", { different_trn: true })
create_fip_ect_with_eligibility("Active Flags", { active_flags: true })

create_fip_mentor_with_eligibility("Eligible")
create_fip_mentor_with_eligibility("Previous Induction", { previous_induction: true })
create_fip_mentor_with_eligibility("Previous Participation ERO", { previous_participation: true })
create_fip_mentor_with_eligibility("No QTS", { qts: false })
create_fip_mentor_with_eligibility("Different TRN", { different_trn: true })
create_fip_mentor_with_eligibility("Active Flags", { active_flags: true })

create_cip_ect_with_eligibility("Eligible")
create_cip_ect_with_eligibility("Previous Induction", { previous_induction: true })
create_cip_ect_with_eligibility("No QTS", { qts: false })
create_cip_ect_with_eligibility("Different TRN", { different_trn: true })
create_cip_ect_with_eligibility("Active Flags", { active_flags: true })

create_cip_mentor_with_eligibility("Eligible")
create_cip_mentor_with_eligibility("Previous Induction", { previous_induction: true })
create_cip_mentor_with_eligibility("Previous Participation ERO", { previous_participation: true })
create_cip_mentor_with_eligibility("No QTS", { qts: false })
create_cip_mentor_with_eligibility("Different TRN", { different_trn: true })
create_cip_mentor_with_eligibility("Active Flags", { active_flags: true })

LeadProvider.all.map(&:name).each do |provider|
  ValidTestDataGenerator::LeadProviderPopulater.call(name: provider, total_schools: 1, participants_per_school: 3)
end

NPQLeadProvider.all.map(&:name).each do |provider|
  ValidTestDataGenerator::NPQLeadProviderPopulater.call(name: provider, total_schools: 1, participants_per_school: 3)
end

# NPQ declarations
create_npq_declarations = lambda {
  i = 0
  lambda do |provider_name:, course:, state:, count:|
    count.times do
      i += 1
      trn = "123#{sprintf('%03d', i)}"
      email_name = [provider_name.split(" ").first.downcase, course].join("-")
      user = User.find_or_create_by!(email: "#{email_name}-#{i}@example.com") do |u|
        u.full_name = "NPQ #{i}"
      end

      teacher_profile = TeacherProfile.find_or_create_by!(user:) do |p|
        p.trn = trn
      end

      npq_application = NPQ::BuildApplication.call(
        npq_application_params: {
          active_alert: true,
          date_of_birth: rand(23..50).years.ago + rand(0..364).days,
          teacher_reference_number: trn,
          eligible_for_funding: state != "submitted",
          funding_choice: NPQApplication.funding_choices.keys.sample,
          headteacher_status: NPQApplication.headteacher_statuses.keys.sample,
          nino: SecureRandom.hex,
          school_urn: "000001",
          school_ukprn: "000001",
          teacher_reference_number_verified: true,
        },
        npq_course_id: NPQCourse.find_by_identifier(course).id,
        npq_lead_provider_id: NPQLeadProvider.find_by_name(provider_name).id,
        user_id: user.id,
      ).tap(&:save!)

      npq_profile = ParticipantProfile::NPQ.find_or_create_by!(teacher_profile:) do |p|
        p.id = npq_application.id
        p.schedule = Finance::Schedule::NPQSpecialist.default
        p.participant_identity = Identity::Create.call(user:, origin: :npq)
      end

      ParticipantProfileState.find_or_create_by!({ participant_profile: npq_profile })

      travel_to npq_application.profile.schedule.milestones.first.start_date + 2.days do
        RecordDeclarations::Started::NPQ.call(
          params: {
            participant_id: npq_application.user.id,
            course_identifier: npq_application.npq_course.identifier,
            declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
            cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
            declaration_type: "started",
          },
        )
      end
    end
  end
}.call

%w[submitted eligible].each do |state|
  create_npq_declarations[
    provider_name: "Ambition Institute",
    course: "npq-headship",
    state:,
    count: 10,
  ]
end
