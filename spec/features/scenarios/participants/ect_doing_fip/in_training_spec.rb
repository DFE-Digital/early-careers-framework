# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECT doing FIP in training", type: :request do
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

  let(:lead_provider_details) do
    NewSeeds::Scenarios::LeadProviders::LeadProvider
      .new(cohorts: [cohort], name: "Lead Provider One")
      .build
      .with_delivery_partner(name: "Delivery Partner One")
  end
  let(:lead_provider) { lead_provider_details.lead_provider }
  let(:delivery_partner) { lead_provider_details.delivery_partner }

  let(:school_details) do
    NewSeeds::Scenarios::Schools::School
      .new(name: "School chosen FIP in 2023")
      .build
      .with_an_induction_tutor(accepted_privacy_policy: privacy_policy)
  end
  let(:school) { school_details.school }

  let(:school_cohort_details) do
    NewSeeds::Scenarios::SchoolCohorts::Fip
      .new(cohort:, school:)
      .build
      .with_partnership(lead_provider:, delivery_partner:)
      .with_programme(default_induction_programme: true)
  end
  let(:school_cohort) { school_cohort_details.school_cohort }

  let(:scenario) { NewSeeds::Scenarios::Participants::Ects::EctInTraining }

  let!(:participant_details) { scenario.new(school_cohort:).build(appropriate_body:) }
  let(:teacher_profile) { participant_details.teacher_profile }
  let(:participant_profile) { participant_details.participant_profile }
  let(:preferred_identity) { participant_details.participant_identity }

  include_examples "As their current school induction tutor"
  include_examples "As their current appropriate body"
  include_examples "As their current lead provider"
  include_examples "As their current delivery provider"
  include_examples "As the support for ECTs service", programme_type: "full_induction_programme"

  # as a DfE Admin user

  # as a DfE Finance user
end
