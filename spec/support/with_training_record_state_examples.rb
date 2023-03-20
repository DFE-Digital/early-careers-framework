# frozen_string_literal: true

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

RSpec.shared_context "with Training Record state examples", shared_context: :metadata do
  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  let(:cip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_cip_with_materials_in(cohort:)
  end
  let(:fip_school) do
    NewSeeds::Scenarios::Schools::School
      .new
      .build
      .chosen_fip_and_partnered_in(cohort:)
  end

  let(:ect_on_cip_being_trained) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_fip_being_trained) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme)
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_from_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_from_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_cip_having_deferred_their_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_fip_having_deferred_their_training) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, training_status: "deferred")
      .participant_profile
  end

  let(:ect_on_cip_withdrawn_from_programme) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: cip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: cip_school.school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end

  let(:ect_on_fip_withdrawn_from_programme) do
    NewSeeds::Scenarios::Participants::Ects::Ect
      .new(school_cohort: fip_school.school_cohort)
      .build
      .with_validation_data
      .with_eligibility
      .with_induction_record(induction_programme: fip_school.school_cohort.default_induction_programme, induction_status: "withdrawn")
      .participant_profile
  end
end

RSpec.configure do |config|
  config.include_context "with default schedules", :with_training_record_state_examples
  config.include_context "with Training Record state examples", :with_training_record_state_examples
end
