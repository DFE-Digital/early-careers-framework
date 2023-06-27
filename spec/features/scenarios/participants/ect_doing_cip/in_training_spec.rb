# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECT doing CIP in training", type: :request do
  let(:start_year) { 2023 }
  let(:cohort) do
    cohort = NewSeeds::Scenarios::Cohorts::Cohort
               .new(start_year:)
               .build
               .with_schedule_and_milestone
               .cohort

    allow(Cohort).to receive(:current).and_return(cohort)
    cohort
  end

  let(:privacy_policy) do
    privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let(:appropriate_body) { FactoryBot.create :seed_appropriate_body, :teaching_school_hub, name: "Appropriate Body One" }

  let(:school_details) do
    NewSeeds::Scenarios::Schools::School
      .new(name: "School chosen CIP in 2023")
      .build
      .with_an_induction_tutor(accepted_privacy_policy: privacy_policy)
  end
  let(:school) { school_details.school }

  let(:school_cohort_details) do
    core_induction_programme = FactoryBot.create :seed_core_induction_programme, name: "Education Development Trust"

    NewSeeds::Scenarios::SchoolCohorts::Cip
      .new(cohort:, school:)
      .build
      .with_programme(core_induction_programme:, default_induction_programme: true)
  end
  let(:school_cohort) { school_cohort_details.school_cohort }

  let(:scenario) { NewSeeds::Scenarios::Participants::Ects::EctInTraining }

  let!(:participant_details) { scenario.new(school_cohort:).build(appropriate_body:) }
  let(:teacher_profile) { participant_details.teacher_profile }
  let(:participant_profile) { participant_details.participant_profile }
  let(:preferred_identity) { participant_details.participant_identity }

  include_examples "As their current school induction tutor"
  include_examples "As their current appropriate body"
  include_examples "As the support for ECTs service", programme_type: "core_induction_programme", materials: "edt"

  # as a DfE Admin user

  # as a DfE Finance user
end
