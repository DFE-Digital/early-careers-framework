# frozen_string_literal: true

def padded_urn(num)
  num.to_s.rjust(6, "0")
end

previous_cohort = Cohort.within_next_registration_period? ? Cohort.current : Cohort.previous
current_cohort = Cohort.active_registration_cohort

# pilot_schools = []
next_urn = 110

school_data = [
  #   cohort, name, with AB, in pilot
  [
    [previous_cohort, "Freddy", false, false],
    [previous_cohort, "Colin", false, false],
    [previous_cohort, "Debbie", false, false],
    [previous_cohort, "Norma", false, false],
    [previous_cohort, "Claire", false, false],
  ],
  [
    [previous_cohort, "Felicity", true, false],
    [previous_cohort, "Cathy", true, false],
    [previous_cohort, "Daniel", true, false],
    [previous_cohort, "Nancy", true, false],
    [previous_cohort, "Cuthbert", true, false],
  ],
  [
    [current_cohort, "Francis", false, true],
    [current_cohort, "Charlie", false, true],
    [current_cohort, "David", false, true],
    [current_cohort, "Neil", false, true],
    [current_cohort, "Christine", false, true],
  ],
  [
    [current_cohort, "Fiona", true, true],
    [current_cohort, "Chloe", true, true],
    [current_cohort, "Dexter", true, true],
    [current_cohort, "Nigel", true, true],
    [current_cohort, "Casper", true, true],
  ],
]

ActiveRecord::Base.transaction do
  school_data.each do |row|
    # FIP School
    cohort, sit_name, with_appropriate_body, in_pilot = row[0]
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - FIP #{cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "#{sit_name} Fip", email: "#{sit_name.downcase}.fip@example.com")
      .chosen_fip_and_partnered_in(cohort:, with_appropriate_body:)

    next_urn += 1
    school_cohort = school.school_cohorts[cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees

    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # CIP School
    cohort, sit_name, with_appropriate_body, in_pilot = row[1]
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - CIP #{cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "#{sit_name} Cip", email: "#{sit_name.downcase}.cip@example.com")
      .chosen_cip_with_materials_in(cohort:, with_appropriate_body:)

    next_urn += 1
    school_cohort = school.school_cohorts[cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees

    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # DIY School
    cohort, sit_name, _, in_pilot = row[2]
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - DIY #{cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "#{sit_name} Diy", email: "#{sit_name.downcase}.diy@example.com")
      .chosen_diy_in(cohort:)

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # School with no ECTs
    cohort, sit_name, _, in_pilot = row[3]
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - No ECTs #{cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "#{sit_name} Noects", email: "#{sit_name.downcase}.noects@example.com")
      .chosen_no_ects_in(cohort:)

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # School that hasn't engaged
    cohort, sit_name, _, in_pilot = row[4]
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - Cohortless #{cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "#{sit_name} Cohortless", email: "#{sit_name.downcase}.cohortless@example.com")

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot
  end
end
