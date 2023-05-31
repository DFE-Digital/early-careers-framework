# frozen_string_literal: true

def create_116780!(lead_provider:, delivery_partner:, cohorts:, another_lead_provider:, another_delivery_partner:)
  NewSeeds::Scenarios::Schools::School
  .new(urn: "116780", name: "Abberley Parochial VC Primary School")
  .build
  .with_an_induction_tutor(full_name: "Induction Tutor", email: "inductiontutor@ambition.org.uk")
  .tap do |school|
    cohorts.each do |cohort|
      partnership = FactoryBot.create(:seed_partnership,
                                      :with_lead_provider,
                                      :with_delivery_partner,
                                      lead_provider:,
                                      delivery_partner:,
                                      cohort:,
                                      school: school.school)
      school.chosen_fip_and_partnered_in(cohort:, partnership:)
    end
    NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort: school.school_cohorts[cohorts.last.start_year])
                                                 .build(default_induction_programme: false)
                                                 .with_relationship(lead_provider: another_lead_provider,
                                                                    delivery_partner: another_delivery_partner)
  end
end

def create_144181!(lead_provider:, delivery_partner:, cohorts:)
  NewSeeds::Scenarios::Schools::School
  .new(urn: "144181", name: "Abbeyfields First School")
  .build
  .with_an_induction_tutor(full_name: "ambition tutor", email: "ambition-induction-tutor@example.com")
  .tap do |school|
    cohorts.each do |cohort|
      partnership = FactoryBot.create(:seed_partnership,
                                      :with_lead_provider,
                                      :with_delivery_partner,
                                      lead_provider:,
                                      delivery_partner:,
                                      cohort:,
                                      school: school.school)
      school.chosen_fip_and_partnered_in(cohort:, partnership:)
    end
  end
end

def create_123780!(cohorts:)
  NewSeeds::Scenarios::Schools::School
  .new(urn: "123780", name: "West Pennard Church of England Primary School")
  .build
  .with_an_induction_tutor(full_name: "ambition tutor", email: "school-123780-induction-tutor@example.com")
  .tap do |school|
    cohorts.each { |cohort| school.chosen_fip_but_not_partnered(cohort:) }
  end
end

def create_ect!(school_cohort:, start_date: Time.current, **opts)
  full_name = opts[:full_name] || ::Faker::Name.name
  email = Faker::Internet.email(name: full_name)
  trn = rand(100_000..999_999).to_s
  date_of_birth = rand(25..50).years.ago + rand(0..365).days
  nino = SecureRandom.hex

  EarlyCareerTeachers::Create.call(full_name:,
                                   email:,
                                   school_cohort:,
                                   start_date:,
                                   mentor_profile_id: nil,
                                   sit_validation: true).tap do |ect|
    StoreValidationResult.new(
      participant_profile: ect,
      validation_data: {
        trn:,
        full_name:,
        dob: date_of_birth,
        nino:,
      },
      dqt_response: {
        trn:,
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      },
      deduplicate: true,
    ).call

    RecordDeclaration.new(
      participant_id: ect.user.id,
      course_identifier: "ecf-induction",
      declaration_date: (ect.schedule.milestones.where(declaration_type: "started").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: ect.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "started",
    ).call

    RecordDeclaration.new(
      participant_id: ect.user.id,
      course_identifier: "ecf-induction",
      declaration_date: (ect.schedule.milestones.where(declaration_type: "retained-1").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: ect.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-1",
      evidence_held: "other",
    ).call

    RecordDeclaration.new(
      participant_id: ect.user.id,
      course_identifier: "ecf-induction",
      declaration_date: (ect.schedule.milestones.where(declaration_type: "retained-2").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: ect.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-2",
      evidence_held: "other",
    ).call
  end
end

def create_mentor!(school_cohort:, start_date: Time.current, **opts)
  full_name = opts[:full_name] || ::Faker::Name.name
  email = Faker::Internet.email(name: full_name)
  trn = rand(100_000..999_999).to_s
  date_of_birth = rand(25..50).years.ago + rand(0..365).days
  nino = SecureRandom.hex

  Mentors::Create.call(full_name:,
                       email:,
                       school_cohort:,
                       start_date:,
                       sit_validation: true).tap do |mentor|

    StoreValidationResult.new(
      participant_profile: mentor,
      validation_data: {
        trn:,
        full_name:,
        dob: date_of_birth,
        nino:,
      },
      dqt_response: {
        trn:,
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      },
      deduplicate: true,
    ).call

    RecordDeclaration.new(
      participant_id: mentor.user.id,
      course_identifier: "ecf-mentor",
      declaration_date: (mentor.schedule.milestones.where(declaration_type: "started").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: mentor.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "started",
    ).call

    RecordDeclaration.new(
      participant_id: mentor.user.id,
      course_identifier: "ecf-mentor",
      declaration_date: (mentor.schedule.milestones.where(declaration_type: "retained-1").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: mentor.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-1",
      evidence_held: "other",
    ).call
    RecordDeclaration.new(
      participant_id: mentor.user.id,
      course_identifier: "ecf-mentor",
      declaration_date: (mentor.schedule.milestones.where(declaration_type: "retained-2").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: mentor.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-2",
      evidence_held: "other",
    ).call
  end
end

def create_ect_becoming_mentor!(ect_school_cohort:, mentor_school_cohort:, **opts)
  full_name = opts[:full_name] || ::Faker::Name.name
  email = Faker::Internet.email(name: full_name)
  trn = rand(100_000..999_999).to_s
  date_of_birth = rand(25..50).years.ago + rand(0..365).days
  nino = SecureRandom.hex

  ect = EarlyCareerTeachers::Create.call(
    full_name:,
    email:,
    school_cohort: ect_school_cohort,
    mentor_profile_id: nil,
    sit_validation: true,
  )

  StoreValidationResult.new(
    participant_profile: ect,
    validation_data: {
      trn:,
      full_name:,
      dob: date_of_birth,
      nino:,
    },
    dqt_response: {
      trn:,
      qts: true,
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
    },
    deduplicate: true,
  ).call

  preferred_email = ect.participant_identity.email

  mentor_profile = ParticipantProfile::Mentor.create!(
    teacher_profile: ect.teacher_profile,
    participant_identity: ect.participant_identity,
    schedule: Finance::Schedule::ECF.default_for(cohort: mentor_school_cohort.cohort),
    sparsity_uplift: false,
    pupil_premium_uplift: false,
    school_cohort: mentor_school_cohort,
  )

  ParticipantProfileState.create!(participant_profile: mentor_profile,
                                  cpd_lead_provider: mentor_school_cohort&.default_induction_programme&.lead_provider&.cpd_lead_provider)

  if mentor_school_cohort.default_induction_programme.present?
    Induction::Enrol.call(participant_profile: mentor_profile,
                          induction_programme: mentor_school_cohort.default_induction_programme,
                          preferred_email:,
                          start_date: mentor_profile.schedule.milestones.where(declaration_type: "started").first.start_date - 1.day)
  end

  Mentors::AddToSchool.call(school: mentor_school_cohort.school, mentor_profile:, preferred_email:)

  StoreValidationResult.new(
    participant_profile: mentor_profile,
    validation_data: {
      trn:,
      full_name:,
      dob: date_of_birth,
      nino:,
    },
    dqt_response: {
      trn:,
      qts: true,
      active_alert: false,
      previous_participation: false,
      previous_induction: false,
    },
    deduplicate: true,
  ).call

  [ect, mentor_profile]
end

# Cohorts
cohort_2021 = Cohort.find_by(start_year: 2021) || FactoryBot.create(:seed_cohort, start_year: 2021)
cohort_2022 = Cohort.find_by(start_year: 2022) || FactoryBot.create(:seed_cohort, start_year: 2022)
cohort_2023 = Cohort.find_by(start_year: 2023) || FactoryBot.create(:seed_cohort, start_year: 2023)

# Lead providers and Delivery partners
ambition = LeadProvider.find_by_name("Ambition Institute")
teach_first = LeadProvider.find_by_name("Teach First")
hampshire = FactoryBot.create(:seed_delivery_partner, name: "Hampshire Local Authority")
five_counties = FactoryBot.create(:seed_delivery_partner, name: "Five Counties Teaching School Hubs Alliance")
[cohort_2021, cohort_2022, cohort_2023].each do |cohort|
  FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider: ambition, delivery_partner: hampshire)
  FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider: ambition, delivery_partner: five_counties)
  FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider: teach_first, delivery_partner: five_counties)
end

# Schools
# School 116780 with a FIP partnership ambition/hampshire for 2021, 2022 and 2023 cohorts
school_116780 = create_116780!(lead_provider: ambition,
                               delivery_partner: hampshire,
                               cohorts: [cohort_2021, cohort_2022, cohort_2023],
                               another_lead_provider: teach_first,
                               another_delivery_partner: five_counties).school

# School 144181 with a FIP partnership ambition/five_counties for 2021 and 2022 cohorts
school_144181 = create_144181!(lead_provider: ambition, delivery_partner: five_counties, cohorts: [cohort_2021, cohort_2022]).school

# School 123780 with no cohorts or induction tutor setup
school_123780 = create_123780!(cohorts: [cohort_2022]).school

# Create ECTs and Mentors
[[school_116780, cohort_2021],
 [school_116780, cohort_2022],
 [school_144181, cohort_2021],
 [school_144181, cohort_2022]].each do |(school, cohort)|
  school_cohort = school.school_cohorts.where(cohort:).first
  10.times.each { create_ect!(school_cohort:) }
  10.times.each { create_mentor!(school_cohort:) }
end

# Create ECTs becoming Mentors
[school_116780].each do |school|
  school_cohort_1 = school.school_cohorts.where(cohort: cohort_2021).first
  school_cohort_2 = school.school_cohorts.where(cohort: cohort_2022).first
  10.times.each do
    create_ect_becoming_mentor!(ect_school_cohort: school_cohort_1, mentor_school_cohort: school_cohort_2)
  end
end


# Testing scenarios

school_116780_cohort_2022 = school_116780.school_cohorts.where(cohort: cohort_2022).first
school_116780_cohort_2023 = school_116780.school_cohorts.where(cohort: cohort_2023).first

# ect with an induction record in 2022 and another in 2023.
participant_profile = create_ect!(school_cohort: school_116780_cohort_2023, full_name: "Two Cohorts", start_date: 10.days.ago)
induction_programme = school_116780_cohort_2022.default_induction_programme
participant_profile.latest_induction_record.changing!
Induction::Enrol.new(participant_profile:, induction_programme:, start_date: Time.current).call

# ect with 2 active induction records, named "Two Active IRs" on 2022 at school 116780
ect = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "Two Active IRs", start_date: nil)
ir1 = ect.latest_induction_record
InductionRecord.create!(start_date: Time.current,
                        mentor_profile_id: school_116780.mentor_profile_ids.first,
                        **ir1.attributes.except("id", "created_at", "updated_at", "start_date", "mentor_profile_id"))

# ect with a gap in their induction records.
participant_profile = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "Gap IRs", start_date: nil)
induction_programme = participant_profile.latest_induction_record.induction_programme
participant_profile.latest_induction_record.changing!(2.days.ago)
Induction::Enrol.new(participant_profile:, induction_programme:, start_date: Time.current).call

# ect with overlapping induction records.
participant_profile = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "Overlapping IRs", start_date: 3.days.ago)
induction_programme = participant_profile.latest_induction_record.induction_programme
participant_profile.latest_induction_record.changing!
Induction::Enrol.new(participant_profile:, induction_programme:, start_date: 2.days.ago).call

# transfer within a school
participant_profile = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "Transfer Within School", start_date: nil)
participant_profile.latest_induction_record.leaving!
induction_programme = participant_profile.latest_induction_record.induction_programme
Induction::Enrol.new(participant_profile:, induction_programme:, start_date: Time.current, school_transfer: true).call

# transfer FIP to FIP with no partnership
participant_profile = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "FIP To FIPNoProvider", start_date: 15.days.ago)
induction_programme = school_123780.school_cohorts.where(cohort: cohort_2022).first.default_induction_programme
Induction::TransferToSchoolsProgramme.call(participant_profile:, induction_programme:, email: "fiptofipnoprovider@example.com")

# change LP inside same school
participant_profile = create_ect!(school_cohort: school_116780_cohort_2023, full_name: "FIP To FIPNoProvider", start_date: 15.days.ago)
new_induction_programme = school_116780_cohort_2023.induction_programmes.joins(partnership: :lead_provider).where(partnerships: { lead_provider_id: teach_first.id }).first
Induction::ChangeProgramme.call(participant_profile:, end_date: Time.current, new_induction_programme:)

# ECT-Mentor inside same school, same provider
create_ect_becoming_mentor!(full_name: "ECT Becoming Mentor", ect_school_cohort: school_116780_cohort_2022, mentor_school_cohort: school_116780_cohort_2023)

# Multi-ECT participant
ect1 = create_ect!(school_cohort: school_116780_cohort_2022, full_name: "Multi ECT")
ect2 = ParticipantProfile::ECT.create!(
  teacher_profile: ect1.teacher_profile,
  schedule: Finance::Schedule::ECF.default_for(cohort: cohort_2023),
  participant_identity: Identity::Create.call(user: ect1.user),
  school_cohort_id: school_116780_cohort_2023.id,
  induction_start_date: cohort_2023.academic_year_start_date,
)
ParticipantProfileState.create!(participant_profile: ect2, cpd_lead_provider: school_116780_cohort_2023&.default_induction_programme&.lead_provider&.cpd_lead_provider)
Induction::Enrol.call(participant_profile: ect2, induction_programme: school_116780_cohort_2023.default_induction_programme)
