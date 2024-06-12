# frozen_string_literal: true

def padded_urn(num)
  num.to_s.rjust(6, "0")
end

previous_cohort = Cohort.within_next_registration_period? ? Cohort.current : Cohort.previous
current_cohort = Cohort.active_registration_cohort

# pilot_schools = []
next_urn = 110

school_data = [
  #   cohort, name, with AB?, in pilot?, school_type_code
  [
    [previous_cohort, "Freddy", false, false, 10],
    [previous_cohort, "Colin", false, false, 11],
    [previous_cohort, "Debbie", false, false, 37],
    [previous_cohort, "Norma", false, false, 10],
    [previous_cohort, "Claire", false, false, 11],
  ],
  [
    [previous_cohort, "Felicity", true, false, 37],
    [previous_cohort, "Cathy", true, false, 10],
    [previous_cohort, "Daniel", true, false, 11],
    [previous_cohort, "Nancy", true, false, 37],
    [previous_cohort, "Cuthbert", true, false, 10],
  ],
  [
    [previous_cohort, "Frank", false, true, 11],
    [previous_cohort, "Carla", false, true, 37],
    [previous_cohort, "Daphne", false, true, 10],
    [previous_cohort, "Nicola", false, true, 11],
    [previous_cohort, "Carlton", false, true, 37],
  ],
  [
    [current_cohort, "Francis", false, true, 10],
    [current_cohort, "Charlie", false, true, 11],
    [current_cohort, "David", false, true, 37],
    [current_cohort, "Neil", false, true, 10],
    [current_cohort, "Christine", false, true, 11],
  ],
  [
    [current_cohort, "Fiona", true, true, 37],
    [current_cohort, "Chloe", true, true, 10],
    [current_cohort, "Dexter", true, true, 11],
    [current_cohort, "Nigel", true, true, 37],
    [current_cohort, "Casper", true, true, 10],
  ],
]

ActiveRecord::Base.transaction do
  school_data.each do |row|
    # FIP School
    cohort, sit_name, with_appropriate_body, in_pilot, school_type_code = row[0]
    ab = with_appropriate_body ? " - AB" : ""
    pilot = in_pilot ? " - PILOT" : ""
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - FIP #{cohort.academic_year} School#{ab}#{pilot} type #{school_type_code}", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "#{sit_name} Fip", email: "#{sit_name.downcase}.#{next_urn}.fip@example.com")
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
    cohort, sit_name, with_appropriate_body, in_pilot, school_type_code = row[1]
    ab = with_appropriate_body ? " - AB" : ""
    pilot = in_pilot ? " - PILOT" : ""
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - CIP #{cohort.academic_year} School#{ab}#{pilot} type #{school_type_code}", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "#{sit_name} Cip", email: "#{sit_name.downcase}.#{next_urn}.cip@example.com")
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
    cohort, sit_name, _, in_pilot, school_type_code = row[2]
    pilot = in_pilot ? " - PILOT" : ""
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - DIY #{cohort.academic_year} School#{pilot} type #{school_type_code}", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "#{sit_name} Diy", email: "#{sit_name.downcase}.#{next_urn}.diy@example.com")
                                                 .chosen_diy_in(cohort:)

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # School with no ECTs
    cohort, sit_name, _, in_pilot, school_type_code = row[3]
    pilot = in_pilot ? " - PILOT" : ""
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - No ECTs #{cohort.academic_year} School#{pilot} type #{school_type_code}", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "#{sit_name} Noects", email: "#{sit_name.downcase}.#{next_urn}.noects@example.com")
                                                 .chosen_no_ects_in(cohort:)

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot

    # School that hasn't engaged
    cohort, sit_name, _, in_pilot, school_type_code = row[4]
    pilot = in_pilot ? " - PILOT" : ""
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - Cohortless #{cohort.academic_year} School#{pilot} type #{school_type_code}", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "#{sit_name} Cohortless", email: "#{sit_name.downcase}.#{next_urn}.cohortless@example.com")

    next_urn += 1
    FeatureFlag.activate(:registration_pilot_school, for: school.school) if in_pilot
  end
end
