# frozen_string_literal: true

# Cohorts
cohort_2021 = Cohort.find_by(start_year: 2021) || FactoryBot.create(:seed_cohort, start_year: 2021)
cohort_2022 = Cohort.find_by(start_year: 2022) || FactoryBot.create(:seed_cohort, start_year: 2022)
cohort_2023 = Cohort.find_by(start_year: 2023) || FactoryBot.create(:seed_cohort, start_year: 2023)

# Lead providers and Delivery partners
ambition = LeadProvider.find_by_name("Ambition Institute")
hampshire = FactoryBot.create(:seed_delivery_partner, name: "Hampshire Local Authority")
five_counties = FactoryBot.create(:seed_delivery_partner, name: "Five Counties Teaching School Hubs Alliance")
[cohort_2021, cohort_2022, cohort_2023].each do |cohort|
  FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider: ambition, delivery_partner: hampshire)
  FactoryBot.create(:seed_provider_relationship, cohort:, lead_provider: ambition, delivery_partner: five_counties)
end

# Schools
# School 116780 with a FIP partnership ambition/hampshire for 2021, 2022 and 2023 cohorts
school = NewSeeds::Scenarios::Schools::School.new(urn: "116780", name: "Abberley Parochial VC Primary School")
                                             .build
                                             .with_an_induction_tutor(full_name: "Induction Tutor",
                                                                      email: "inductiontutor@ambition.org.uk")
lead_provider = ambition
delivery_partner = hampshire

[cohort_2021, cohort_2022, cohort_2023].each do |cohort|
  partnership = FactoryBot.create(:seed_partnership,
                                  :with_lead_provider,
                                  :with_delivery_partner,
                                  lead_provider:,
                                  delivery_partner:,
                                  cohort:,
                                  school: school.school)
  school.chosen_fip_and_partnered_in(cohort:, partnership:)
end

# School 144181 with a FIP partnership ambition/five_counties for 2021 and 2022 cohorts
school = NewSeeds::Scenarios::Schools::School.new(urn: "144181", name: "Abbeyfields First School")
                                             .build
                                             .with_an_induction_tutor(full_name: "ambition tutor",
                                                                      email: "ambition-induction-tutor@example.com")
lead_provider = ambition
delivery_partner = five_counties

[cohort_2021, cohort_2022].each do |cohort|
  partnership = FactoryBot.create(:seed_partnership,
                                  :with_lead_provider,
                                  :with_delivery_partner,
                                  lead_provider:,
                                  delivery_partner:,
                                  cohort:,
                                  school: school.school)
  school.chosen_fip_and_partnered_in(cohort:, partnership:)
end

# School 123780 with no cohorts or induction tutor setup
NewSeeds::Scenarios::Schools::School.new(urn: "123780", name: "West Pennard Church of England Primary School")
                                    .build

# Create ECTs
urn_to_cohort = [["116780", 2021], ["116780", 2022], ["144181", 2021], ["144181", 2022]]
urn_to_cohort.each do |c|
  cohort = Cohort.find_by(start_year: c.second)
  school_cohort = School.find_by(urn: c.first).school_cohorts.where(cohort:).first
  if school_cohort.nil?
    Rails.logger.debug "could not find cohort #{c.second} for urn #{c.first}"
    next
  end

  # create ECTs
  10.times.each do
    full_name = ::Faker::Name.name
    email = Faker::Internet.email(name: full_name)
    trn = rand(100_000..999_999).to_s
    date_of_birth = rand(25..50).years.ago + rand(0..365).days
    nino = SecureRandom.hex

    ect = EarlyCareerTeachers::Create.call(
      full_name:,
      email:,
      school_cohort:,
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

# Create Mentors
urn_to_cohort = [["116780", 2021], ["116780", 2022], ["144181", 2021], ["144181", 2022]]
urn_to_cohort.each do |c|
  cohort = Cohort.find_by(start_year: c.second)
  school_cohort = School.find_by(urn: c.first).school_cohorts.where(cohort:).first
  if school_cohort.nil?
    Rails.logger.debug "could not find cohort #{c.second} for urn #{c.first}"
    next
  end

  # create mentors
  10.times.each do
    full_name = ::Faker::Name.name
    email = Faker::Internet.email(name: full_name)
    trn = rand(100_000..999_999).to_s
    date_of_birth = rand(25..50).years.ago + rand(0..365).days
    nino = SecureRandom.hex

    mentor = Mentors::Create.call(
      full_name:,
      email:,
      school_cohort:,
      sit_validation: true,
    )

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

# Create ECTs becoming Mentors
%w[116780 123780].each do |urn|
  school_cohort_1 = School.find_by(urn:).school_cohorts.where(cohort: cohort_2021).first
  school_cohort_2 = School.find_by(urn:).school_cohorts.where(cohort: cohort_2022).first

  if school_cohort_1.nil? && school_cohort_2.nil?
    Rails.logger.debug "could not find school #{urn}"
    next
  end

  10.times.each do
    full_name = ::Faker::Name.name
    email = Faker::Internet.email(name: full_name)
    trn = rand(100_000..999_999).to_s
    date_of_birth = rand(25..50).years.ago + rand(0..365).days
    nino = SecureRandom.hex

    ect = EarlyCareerTeachers::Create.call(
      full_name:,
      email:,
      school_cohort: school_cohort_1,
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
      schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_2.cohort),
      sparsity_uplift: false,
      pupil_premium_uplift: false,
      school_cohort: school_cohort_2,
    )

    ParticipantProfileState.create!(participant_profile: mentor_profile,
                                    cpd_lead_provider: school_cohort_2&.default_induction_programme&.lead_provider&.cpd_lead_provider)

    if school_cohort_2.default_induction_programme.present?
      Induction::Enrol.call(participant_profile: mentor_profile,
                            induction_programme: school_cohort_2.default_induction_programme,
                            preferred_email:,
                            start_date: mentor_profile.schedule.milestones.where(declaration_type: "started").first.start_date - 1.day)
    end

    Mentors::AddToSchool.call(school: school_cohort_2.school, mentor_profile:, preferred_email:)

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
  end
end
