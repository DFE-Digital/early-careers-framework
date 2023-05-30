# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Setting up the first Academic Year for a School", type: :feature,
              with_feature_flags: { eligibility_notifications: "active" } do
  let!(:previous_cohort) do
    previous_cohort = NewSeeds::Scenarios::Cohort.new(2021)
                                                 .with_standard_schedule_and_first_milestone
                                                 .build
                                                 .cohort

    allow(Cohort).to receive(:previous).and_return(previous_cohort)

    previous_cohort
  end
  let!(:current_cohort) do
    allow(Cohort).to receive(:within_automatic_assignment_period?).and_return(false)
    allow(Cohort).to receive(:within_next_registration_period?).and_return(false)

    current_cohort = NewSeeds::Scenarios::Cohort.new(2022)
                                                .with_standard_schedule_and_first_milestone
                                                .build
                                                .cohort

    allow(Cohort).to receive(:current).and_return(current_cohort)

    current_cohort
  end

  let!(:privacy_policy) do
    privacy_policy = FactoryBot.create(:seed_privacy_policy, :valid)
    PrivacyPolicy::Publish.call
    privacy_policy
  end

  let!(:core_induction_programme) { create :seed_core_induction_programme, :valid }
  let!(:appropriate_body) { create :seed_appropriate_body, :valid }

  let!(:lead_provider) { create :seed_lead_provider, cohorts: Cohort.all }
  let!(:lead_provider_user) { create(:seed_lead_provider_profile, :with_user, lead_provider:).user }
  let!(:delivery_partner) do
    delivery_partner = create(:seed_delivery_partner)
    create :seed_provider_relationship, delivery_partner:, lead_provider:, cohort: current_cohort
    delivery_partner
  end
  let(:school_builder) do
    school = NewSeeds::Scenarios::Schools::School.new
                                                 .build
                                                 .with_an_induction_tutor

    PrivacyPolicy.current.accept! school.induction_tutor
    school
  end

  let(:school) { school_builder.school }
  let(:academic_year) { current_cohort }

  before do
    travel_to Time.zone.local(academic_year.start_year, 6, 1, 9, 0, 0)
  end

  context "before any academic years have been setup" do
    it_behaves_like "a school record", start_year: 2021
    it_behaves_like "a school with an known SIT record", start_year: 2021
    it_behaves_like "a school that needs to be setup", start_year: 2021
  end

  context "after a core induction programme has been setup for the first academic year" do
    before do
      sign_in_as school.induction_tutor

      ::Pages::Schools::Wizards::ChooseProgrammeWizard.loaded
                                                      .choose_cip

      sign_out
    end

    it_behaves_like "a school with an associated school cohort record", start_year: 2022
    it_behaves_like "a school with a default core induction programme record", start_year: 2022
    it_behaves_like "a school that can add a participant", start_year: 2022

    context "and CIP materials has been setup for the first academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                 .choose_academic_year(academic_year:)
                                                                 .start_choose_materials_wizard
                                                                 .report_core_programme_materials(core_programme_materials: core_induction_programme)

        sign_out
      end

      it_behaves_like "a school with a CIP materials record", start_year: 2022
      it_behaves_like "a school that can add a participant", start_year: 2022
    end

    context "and an appropriate body has been setup for the first academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                 .choose_academic_year(academic_year:)
                                                                 .start_add_appropriate_body_wizard
                                                                 .report_appropriate_body(appropriate_body:)

        sign_out
      end

      it_behaves_like "a school with an appropriate body record", start_year: 2022
      it_behaves_like "a school that can add a participant with an appropriate body", start_year: 2022
    end
  end

  context "after a full induction programme has been setup for the first academic year" do
    before do
      sign_in_as school.induction_tutor

      ::Pages::Schools::Wizards::ChooseProgrammeWizard.loaded
                                                      .choose_fip

      sign_out
    end

    it_behaves_like "a school with an associated school cohort record", start_year: 2022
    it_behaves_like "a school with a default full induction programme record", start_year: 2022
    it_behaves_like "a school that can add a participant", start_year: 2022

    context "and a partnership is in place for the first academic year" do
      before do
        given_i_sign_in_as_the_user_with_the_full_name lead_provider_user.full_name

        Pages::LeadProviderDashboard.loaded
                                    .confirm_schools_for(current_cohort)
                                    .complete(delivery_partner.name, [school.urn])

        sign_out
      end

      it_behaves_like "a school with a partnership record", start_year: 2022
      it_behaves_like "a school that can add a participant", start_year: 2022
    end

    context "and an appropriate body has been setup for the first academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                 .choose_academic_year(academic_year:)
                                                                 .start_add_appropriate_body_wizard
                                                                 .report_appropriate_body(appropriate_body:)

        sign_out
      end

      it_behaves_like "a school with an appropriate body record", start_year: 2022
      it_behaves_like "a school that can add a participant with an appropriate body", start_year: 2022
    end
  end

  context "after a design your own induction programme has been setup for the first academic year" do
    before do
      sign_in_as school.induction_tutor

      ::Pages::Schools::Wizards::ChooseProgrammeWizard.loaded
                                                      .choose_diy

      sign_out
    end

    it_behaves_like "a school with an associated school cohort record", start_year: 2022
    it_behaves_like "a school with a default diy induction programme record", start_year: 2022
    it_behaves_like "a school that cannot add a participant without more information", start_year: 2022

    context "and an appropriate body has been setup for the first academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                 .choose_academic_year(academic_year:)
                                                                 .start_add_appropriate_body_wizard
                                                                 .report_appropriate_body(appropriate_body:)

        sign_out
      end

      it_behaves_like "a school with an appropriate body record", start_year: 2022
      it_behaves_like "a school that cannot add a participant without more information", start_year: 2022
    end
  end

  context "after reporting no ECTs expected for the first academic year" do
    before do
      sign_in_as school.induction_tutor

      ::Pages::Schools::Wizards::ChooseProgrammeWizard.loaded
                                                      .choose_no_ects

      sign_out
    end

    it_behaves_like "a school with an associated school cohort record", start_year: 2022
    it_behaves_like "a school with no induction programme record", start_year: 2022
    it_behaves_like "a school that cannot add a participant without more information", start_year: 2022
  end
end
