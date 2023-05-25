urn_to_cohort = [["116780",2021],["116780",2022],["144181",2021],["144181",2022]]

# Create ECTs
urn_to_cohort.each do |c| 
  cohort = Cohort.find_by(start_year: c.second)
  school_cohort = School.find_by(urn: c.first).school_cohorts.where(cohort:).first
  if school_cohort.nil?
    puts "could not find cohort #{c.second} for urn #{c.first}"
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
      evidence_held: "other"
    ).call
    
    RecordDeclaration.new(
      participant_id: ect.user.id,
      course_identifier: "ecf-induction",
      declaration_date: (ect.schedule.milestones.where(declaration_type: "retained-2").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: ect.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-2",
      evidence_held: "other"
    ).call
  end
end


# Create Mentors
urn_to_cohort.each do |c| 
  cohort = Cohort.find_by(start_year: c.second)
  school_cohort = School.find_by(urn: c.first).school_cohorts.where(cohort:).first
  if school_cohort.nil?
    puts "could not find cohort #{c.second} for urn #{c.first}"
    next
  end

  # create mentors
  5.times.each do 
    full_name = ::Faker::Name.name
    email = Faker::Internet.email(name: full_name)
    trn = rand(100_000..999_999).to_s
    date_of_birth =  rand(25..50).years.ago + rand(0..365).days
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
      evidence_held: "other"
    ).call
    RecordDeclaration.new(
      participant_id: mentor.user.id,
      course_identifier: "ecf-mentor",
      declaration_date: (mentor.schedule.milestones.where(declaration_type: "retained-2").first.start_date + 1.day).rfc3339,
      cpd_lead_provider: mentor.induction_records.latest.induction_programme.partnership.lead_provider.cpd_lead_provider,
      declaration_type: "retained-2",
      evidence_held: "other"
    ).call
  end
end


# Create ECTs becoming Mentors
urns = ["116780", "123780"]

cohort_2021 = Cohort.find_by(start_year: 2021)
cohort_2022 = Cohort.find_by(start_year: 2022)

urns.each do |urn|
  school_cohort_1 = School.find_by(urn:).school_cohorts.where(cohort: cohort_2021).first
  school_cohort_2 = School.find_by(urn:).school_cohorts.where(cohort: cohort_2022).first

  if school_cohort_1.nil? && school_cohort_2.nil?
    puts "could not find school #{urn}"
    next
  end

  5.times.each do 
    full_name = ::Faker::Name.name
    email = Faker::Internet.email(name: full_name)
    trn = rand(100_000..999_999).to_s
    date_of_birth =  rand(25..50).years.ago + rand(0..365).days
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
                              preferred_email: ,
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

