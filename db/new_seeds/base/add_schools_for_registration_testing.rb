# frozen_string_literal: true

def padded_urn(num)
  num.to_s.rjust(6, "0")
end

previous_cohort = Cohort.within_next_registration_period? ? Cohort.current : Cohort.previous
current_cohort = Cohort.active_registration_cohort

next_urn = 110

ActiveRecord::Base.transaction do
  # Previous cohort
  # School that ran FIP "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - FIP #{previous_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Freddy Fip", email: "freddy.fip@example.com")
      .chosen_fip_and_partnered_in(cohort: previous_cohort)

    next_urn += 1
    school_cohort = school.school_cohorts[previous_cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees
  end

  # School that ran CIP "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - CIP #{previous_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Colin Cip", email: "colin.cip@example.com")
      .chosen_cip_with_materials_in(cohort: previous_cohort)

    next_urn += 1
    school_cohort = school.school_cohorts[previous_cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees
  end

  # School that ran DIY "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - DIY #{previous_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Debbie Diy", email: "debbie.diy@example.com")
      .chosen_diy_in(cohort: previous_cohort)

    next_urn += 1
  end

  # School that had no ECTs "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - No ECTs #{previous_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Norma Noects", email: "norma.noects@example.com")
      .chosen_no_ects_in(cohort: previous_cohort)

    next_urn += 1
  end

  # School that didnt engage "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - Cohortless #{previous_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Claire Cohortless", email: "claire.cohortless@example.com")

    next_urn += 1
  end

  #### Current registration cohort
  # School that has chosen FIP
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - FIP #{current_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Felicity Fip", email: "felicity.fip@example.com")
      .chosen_fip_and_partnered_in(cohort: current_cohort)

    next_urn += 1
    school_cohort = school.school_cohorts[current_cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees
  end

  # School that has chosen CIP
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - CIP #{current_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Cathy Cip", email: "cathy.cip@example.com")
      .chosen_cip_with_materials_in(cohort: current_cohort)

    next_urn += 1
    school_cohort = school.school_cohorts[current_cohort.start_year]

    NewSeeds::Scenarios::Participants::Mentors::MentorWithSomeEcts.new(school_cohort:)
      .build
      .with_induction_record(induction_programme: school_cohort.default_induction_programme)
      .with_validation_data
      .with_eligibility
      .with_mentees
  end

  # School that has chosen DIY
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - DIY #{current_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Daniel Diy", email: "daniel.diy@example.com")
      .chosen_diy_in(cohort: current_cohort)

    next_urn += 1
  end

  # School that had no ECTs "last" year
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - No ECTs #{current_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Nigel Noects", email: "nigel.noects@example.com")
      .chosen_no_ects_in(cohort: current_cohort)

    next_urn += 1
  end

  # School that hasn't engaged
  begin
    school = NewSeeds::Scenarios::Schools::School.new(name: "Reg - Cohortless #{current_cohort.academic_year} School", urn: padded_urn(next_urn))
      .build
      .with_an_induction_tutor(full_name: "Craig Cohortless", email: "craig.cohortless@example.com")

    next_urn += 1

  end
end
