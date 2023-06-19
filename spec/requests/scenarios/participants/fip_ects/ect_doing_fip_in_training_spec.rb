# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ECT doing FIP in training", :with_default_schedules, type: :request do
  let(:cohort_details) do
    NewSeeds::Scenarios::Cohorts::Cohort.new(start_year: 2023)
                                                      .with_standard_schedule_and_first_milestone
                                                      .build
  end
  let(:cohort) { cohort_details.cohort }

  let!(:privacy_policy) do
    privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let(:school_details) do
    school = NewSeeds::Scenarios::Schools::School.new(name: "School chosen FIP for #{cohort.start_year}")
                                                 .build
                                                 .with_an_induction_tutor
                                                 .with_partnership_in(cohort:)
                                                 .chosen_fip_and_partnered_in(cohort:)

    privacy_policy.accept! school.induction_tutor
    school
  end
  let(:school_cohort) { school_details.school_cohort }
  let(:school_slug) { school_details.school.slug }

  subject!(:participant) { NewSeeds::Scenarios::Participants::Ects::EctInTraining.new(school_cohort:).build }

  context "As their current school induction tutor" do
    before { sign_in school_details.induction_tutor }

    it "can see their records in the Manage ECTS and Mentors dashboard" do
      get "/schools/#{school_slug}/participants"

      # expect(response).to be_successful
      expect(response.body).to include subject.full_name
    end

    after { sign_out }
  end
end
