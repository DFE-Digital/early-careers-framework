# frozen_string_literal: true

# generate some bits of data we'll need below first, roughly sticking to the
# structure from the legacy seeds but this time spanning two cohorts (2021,
# 2022) and three lead provoders

school_cohort_one = FactoryBot.create(:seed_school_cohort, :cip, :valid, :starting_in_2021)
induction_programme_one = FactoryBot.create(:seed_induction_programme, :cip, school_cohort: school_cohort_one)

school_cohort_two = FactoryBot.create(:seed_school_cohort, :cip, :valid, :starting_in_2021)
induction_programme_two = FactoryBot.create(:seed_induction_programme, :fip, school_cohort: school_cohort_two)

school_cohort_three = FactoryBot.create(:seed_school_cohort, :fip, :valid, :starting_in_2021)
induction_programme_three = FactoryBot.create(:seed_induction_programme, :cip, school_cohort: school_cohort_three)

school_cohort_four = FactoryBot.create(:seed_school_cohort, :cip, :valid, :starting_in_2022)
induction_programme_four = FactoryBot.create(:seed_induction_programme, :cip, school_cohort: school_cohort_four)

school_cohort_five = FactoryBot.create(:seed_school_cohort, :cip, :valid, :starting_in_2022)
induction_programme_five = FactoryBot.create(:seed_induction_programme, :cip, school_cohort: school_cohort_five)

school_cohort_six = FactoryBot.create(:seed_school_cohort, :fip, :valid, :starting_in_2022)
induction_programme_six = FactoryBot.create(:seed_induction_programme, :fip, school_cohort: school_cohort_six)

ambition = CoreInductionProgramme.find_by!(name: "Ambition Institute")
edt = CoreInductionProgramme.find_by!(name: "Education Development Trust")
ucl = CoreInductionProgramme.find_by!(name: "UCL Institute of Education")

# first some generic mentors

[
  OpenStruct.new(
    full_name: "Sally Mentor",
    email: "rp-mentor.ambition.2021@example.com",
    core_induction_programme: ambition,
    school_cohort: school_cohort_one,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_one.cohort),
    induction_programme: induction_programme_one,
  ),
  OpenStruct.new(
    full_name: "Bjorn Mentor",
    email: "rp-mentor.edt.2021@example.com",
    core_induction_programme: edt,
    school_cohort: school_cohort_two,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_two.cohort),
    induction_programme: induction_programme_two,
  ),
  OpenStruct.new(
    full_name: "Abdul Mentor",
    email: "rp-mentor.ucl.2021@example.com",
    core_induction_programme: ucl,
    school_cohort: school_cohort_three,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_three.cohort),
    induction_programme: induction_programme_three,
  ),

  OpenStruct.new(
    full_name: "Claire Mentor",
    email: "rp-mentor.ambition.2022@example.com",
    core_induction_programme: ambition,
    school_cohort: school_cohort_four,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_four.cohort),
    induction_programme: induction_programme_four,
  ),
  OpenStruct.new(
    full_name: "Rita Mentor",
    email: "rp-mentor.edt.2022@example.com",
    core_induction_programme: edt,
    school_cohort: school_cohort_five,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_five.cohort),
    induction_programme: induction_programme_five,
  ),
  OpenStruct.new(
    full_name: "Luigi Mentor",
    email: "rp-mentor.ucl.2022@example.com",
    core_induction_programme: ucl,
    school_cohort: school_cohort_six,
    schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort_six.cohort),
    induction_programme: induction_programme_six,
  ),
].each do |mentor_params|
  NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
    .new(full_name: mentor_params.full_name)
    .build(
      school_cohort: mentor_params.school_cohort,
      schedule: mentor_params.schedule,
    )
    .add_induction_record(induction_programme: mentor_params.induction_programme)
end
