# frozen_string_literal: true

def padded_urn(num)
  num.to_s.rjust(6, "0")
end

previous_cohort = Cohort.previous
current_cohort = Cohort.current
cohorts_name = sprintf("%02d/%02d", previous_cohort.start_year % 100, current_cohort.start_year % 100)
next_urn = 10

ActiveRecord::Base.transaction do
  # schools without cohorts or partnerships set up
  NewSeeds::Scenarios::Schools::School.new(name: "Cohortless Empty School FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Ethel Emptyfip", email: "ethel.emptyfip@example.com")

  next_urn += 1

  NewSeeds::Scenarios::Schools::School.new(name: "Cohortless Empty School CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Eddie Emptycip", email: "eddie.emptycip@example.com")

  next_urn += 1

  # Schools with a partnership set up with a cohort only with registered mentors and ECTS
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{previous_cohort.start_year}-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Terry Fip", email: "terry.fip@example.com")
    .chosen_fip_and_partnered_in(cohort: previous_cohort)

  next_urn += 1
  school_cohort = school.school_cohorts[previous_cohort.start_year]

  2.times do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility

    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{previous_cohort.start_year}-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Carly Cip", email: "carly.cip@example.com")
    .chosen_cip_with_materials_in(cohort: previous_cohort)

  next_urn += 1
  school_cohort = school.school_cohorts[previous_cohort.start_year]

  2.times do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility

    NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
  end

  # Schools with a partnership set up with a cohort only with no registered mentors or ECTs
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{current_cohort.start_year}-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Tabitha Fip", email: "tabitha.fip@example.com")
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless Second School #{current_cohort.start_year}-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Margaret Fip", email: "margaret.fip@example.com")
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  (0..40).each do |_num|
    # Independent school
    school = NewSeeds::Scenarios::Schools::School.new(name: "School #{next_urn} type 10 #{current_cohort.start_year}-FIP", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "SIT School #{next_urn} type 10", email: "sit.school.10@example.com")
                                                 .chosen_fip_and_partnered_in(cohort: current_cohort)
    school.school.update!(school_type_code: "10")

    next_urn += 1

    # Independent school
    school = NewSeeds::Scenarios::Schools::School.new(name: "School #{next_urn} type 11 #{current_cohort.start_year}-FIP", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "SIT School #{next_urn} type 11", email: "sit.school.11@example.com")
                                                 .chosen_fip_and_partnered_in(cohort: current_cohort)
    school.school.update!(school_type_code: "11")

    next_urn += 1

    # School overseas
    school = NewSeeds::Scenarios::Schools::School.new(name: "School #{next_urn} type 37 #{current_cohort.start_year}-FIP", urn: padded_urn(next_urn))
                                                 .build
                                                 .with_an_induction_tutor(full_name: "SIT School #{next_urn} type 37", email: "sit.school.37@example.com")
                                                 .chosen_fip_and_partnered_in(cohort: current_cohort)
    school.school.update!(school_type_code: "37")

    next_urn += 1
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{current_cohort.start_year}-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Charlie Cip", email: "charlie.cip@example.com")
    .chosen_cip_with_materials_in(cohort: current_cohort)

  next_urn += 1

  # Schools with a partnership set up with cohorts with registered ECTs and registered Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{previous_cohort.academic_year}-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Tracey Fip", email: "tracey.fip@example.com")
    .chosen_fip_and_partnered_in(cohort: previous_cohort)
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  # Schools with a partnership set up with cohorts with registered ECTs and registered Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Mary Fip", email: "mary.fip@example.com")
    .chosen_fip_and_partnered_in(cohort: previous_cohort)
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility

      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Colin Cip", email: "colin.cip@example.com")
    .chosen_cip_with_materials_in(cohort: previous_cohort)
    .chosen_cip_with_materials_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility

      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  # Schools with a partnership set up with cohorts with registered ECTs but no Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-FIP No Mentors", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Trevor Fip-NoMentors", email: "trevor.fip.nomentors@example.com")
    .chosen_fip_and_partnered_in(cohort: previous_cohort)
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-CIP No Mentors", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Coleen Cip-NoMentors", email: "coleen.cip.nomentors@example.com")
    .chosen_cip_with_materials_in(cohort: previous_cohort)
    .chosen_cip_with_materials_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  # Schools with a partnership set up with cohorts with no ECTs and registered Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-FIP-NoECTs", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Thomas Fip-NoECTs", email: "thomas.fip.noects@example.com")
    .chosen_fip_and_partnered_in(cohort: previous_cohort)
    .chosen_fip_and_partnered_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School #{cohorts_name}-CIP-NoECTs", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Clare Cip-NoECTs", email: "clare.cip.noects@example.com")
    .chosen_cip_with_materials_in(cohort: previous_cohort)
    .chosen_cip_with_materials_in(cohort: current_cohort)

  next_urn += 1

  [previous_cohort.start_year, current_cohort.start_year].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end
end
