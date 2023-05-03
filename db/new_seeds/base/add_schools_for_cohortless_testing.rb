# frozen_string_literal: true

def padded_urn(num)
  num.to_s.rjust(6, "0")
end

cohort_22 = Cohort.find_by(start_year: 2022) || FactoryBot.create(:seed_cohort, start_year: 2022)
cohort_23 = Cohort.find_by(start_year: 2023) || FactoryBot.create(:seed_cohort, start_year: 2023)
FactoryBot.create(:ecf_schedule, cohort: cohort_23) if Finance::Schedule::ECF.default_for(cohort: cohort_23).blank?

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

  # Schools with a partnership set up with a 2022/2023 cohort only with registered mentors and ECTS
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Terry Twentytwofip", email: "terry.twentytwofip@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_22)

  next_urn += 1
  school_cohort = school.school_cohorts[2022]

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

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Carly Twentytwocip", email: "carly.twentytwocip@example.com")
    .chosen_cip_with_materials_in(cohort: cohort_22)

  next_urn += 1
  school_cohort = school.school_cohorts[2022]

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
  #
  # Schools with a partnership set up with a 2023/2024 cohort only with no registered mentors or ECTs
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 23-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Tabitha Twentythreefip", email: "tabitha.twentythreefip@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_23)

  next_urn += 1

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless Second School 23-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Margaret Second-Twentythreefip", email: "margaret.second.twentythreefip@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_23)

  next_urn += 1

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 23-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Charlie Twentythreecip", email: "charlie.twentythreecip@example.com")
    .chosen_cip_with_materials_in(cohort: cohort_23)

  next_urn += 1

  # Schools with a partnership set up with a 2022/2023 and 2023/2024 cohort with registered ECTs and registered Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-FIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Tracey TwentyTwoAndThreefip", email: "tracey.twentytwoandthreefip@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_22)
    .chosen_fip_and_partnered_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
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

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-CIP", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Colin TwentyTwoAndThreecip", email: "colin.twentytwoandthreecip@example.com")
    .chosen_cip_with_materials_in(cohort: cohort_22)
    .chosen_cip_with_materials_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
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

  # Schools with a partnership set up with a 2022/2023 and 2023/2024 cohort with registered ECTs but no Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-FIP No Mentors", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Trevor TwentyTwoAndThreefip-NoMentors", email: "trevor.twentytwoandthreefip.nomentors@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_22)
    .chosen_fip_and_partnered_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-CIP No Mentors", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Coleen TwentyTwoAndThreecip-NoMentors", email: "coleen.twentytwoandthreecip.nomentors@example.com")
    .chosen_cip_with_materials_in(cohort: cohort_22)
    .chosen_cip_with_materials_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  # Schools with a partnership set up with a 2022/2023 and 2023/2024 cohort with no ECTs and registered Mentors
  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-FIP-NoECTs", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Thomas TwentyTwoAndThreefip-NoECTs", email: "thomas.twentytwoandthreefip.noects@example.com")
    .chosen_fip_and_partnered_in(cohort: cohort_22)
    .chosen_fip_and_partnered_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
    school_cohort = school.school_cohorts[year]

    2.times do
      NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts.new(school_cohort:)
        .build
        .with_induction_record(induction_programme: school_cohort.default_induction_programme)
        .with_validation_data
        .with_eligibility
    end
  end

  school = NewSeeds::Scenarios::Schools::School.new(name: "Cohortless School 22-23-CIP-NoECTs", urn: padded_urn(next_urn))
    .build
    .with_an_induction_tutor(full_name: "Clare TwentyTwoAndThreecip-NoECTs", email: "clare.twentytwoandthreecip.noects@example.com")
    .chosen_cip_with_materials_in(cohort: cohort_22)
    .chosen_cip_with_materials_in(cohort: cohort_23)

  next_urn += 1

  [2022, 2023].each do |year|
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
