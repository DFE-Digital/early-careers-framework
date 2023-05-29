# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Setting up the Second Academic Year for a School", type: :feature,
              with_feature_flags: { eligibility_notifications: "active" } do
  let!(:current_cohort) do
    FactoryBot.create(:seed_cohort, start_year: 2020) # NQT+1 cohort

    previous_cohort = FactoryBot.create(:seed_cohort, start_year: 2021)
    current_cohort = FactoryBot.create(:seed_cohort, start_year: 2022)
    next_cohort = FactoryBot.create(:seed_cohort, start_year: 2023)

    allow(Cohort).to receive(:current).and_return(current_cohort)
    allow(Cohort).to receive(:next).and_return(next_cohort)
    allow(Cohort).to receive(:previous).and_return(previous_cohort)
    allow(Cohort).to receive(:active_registration_cohort).and_return(current_cohort)

    allow(Cohort).to receive(:within_automatic_assignment_period?).and_return(false)
    allow(Cohort).to receive(:within_next_registration_period?).and_return(false)

    current_cohort
  end
  let!(:finance_schedules) do
    current_schedule = FactoryBot.create :seed_finance_schedule, type: "Finance::Schedule::ECF", name: "ECF Standard September", schedule_identifier: "ecf-standard-september", cohort: Cohort.current
    FactoryBot.create :seed_finance_milestone, schedule: current_schedule, name: "Output 1 - Participant Start", declaration_type: "started"

    previous_schedule = FactoryBot.create :seed_finance_schedule, type: "Finance::Schedule::ECF", name: "ECF Standard September", schedule_identifier: "ecf-standard-september", cohort: Cohort.previous
    FactoryBot.create :seed_finance_milestone, schedule: previous_schedule, name: "Output 1 - Participant Start", declaration_type: "started"

    next_schedule = FactoryBot.create :seed_finance_schedule, type: "Finance::Schedule::ECF", name: "ECF Standard September", schedule_identifier: "ecf-standard-september", cohort: Cohort.next
    FactoryBot.create :seed_finance_milestone, schedule: next_schedule, name: "Output 1 - Participant Start", declaration_type: "started"
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
    create :seed_provider_relationship, delivery_partner:, lead_provider:, cohort: Cohort.previous
    create :seed_provider_relationship, delivery_partner:, lead_provider:, cohort: current_cohort
    delivery_partner
  end

  let!(:different_lead_provider) { create :seed_lead_provider, cohorts: Cohort.all }
  let!(:different_lead_provider_user) { create(:seed_lead_provider_profile, :with_user, lead_provider: different_lead_provider).user }
  let!(:different_delivery_partner) do
    different_delivery_partner = create(:seed_delivery_partner)
    create :seed_provider_relationship, delivery_partner: different_delivery_partner, lead_provider:, cohort: current_cohort
    create :seed_provider_relationship, delivery_partner: different_delivery_partner, lead_provider: different_lead_provider, cohort: current_cohort
    different_delivery_partner
  end

  let(:school) { school_builder.school }
  let(:academic_year) { current_cohort }

  before do
    travel_to Time.zone.local(academic_year.start_year, 6, 1, 9, 0, 0)
  end

  context "Given they have chosen a core induction programme for the first academic year" do
    let(:school_builder) do
      school = NewSeeds::Scenarios::Schools::School.new
                                                   .build
                                                   .with_an_induction_tutor
                                                   .chosen_cip_with_materials_in(cohort: Cohort.previous)

      PrivacyPolicy.current.accept! school.induction_tutor
      school
    end

    context "before the second academic year has been setup" do
      it_behaves_like "a school record", start_year: 2021
      it_behaves_like "a school with an known SIT record", start_year: 2021
      it_behaves_like "a school with an associated school cohort record", start_year: 2021
      it_behaves_like "a school with a default core induction programme record", start_year: 2021
    end

    context "When they have setup a core induction programme for the second academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Wizards::SetupNextAcademicYearWizard.loaded
                                                              .choose_cip

        sign_out
      end

      it_behaves_like "a school with an associated school cohort record", start_year: 2022
      it_behaves_like "a school with a default core induction programme record", start_year: 2022
      it_behaves_like "a school that can add a participant", start_year: 2022

      context "and CIP materials has been setup for the second academic year" do
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

      context "and an appropriate body has been setup for the second academic year" do
        before do
          sign_in_as school.induction_tutor

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                   .choose_academic_year(academic_year:)
                                                                   .start_add_appropriate_body_wizard
                                                                   .report_appropriate_body(appropriate_body:)

          sign_out
        end

        it_behaves_like "a school with an appropriate body record", start_year: 2022
        it_behaves_like "a school that can add a participant", start_year: 2022
      end
    end

    context "When they have setup a full induction programme for the second academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Wizards::SetupNextAcademicYearWizard.loaded
                                                              .choose_fip

        sign_out
      end

      it_behaves_like "a school with an associated school cohort record", start_year: 2022
      it_behaves_like "a school with a default full induction programme record", start_year: 2022
      it_behaves_like "a school that can add a participant", start_year: 2022

      context "and a partnership is in place for the second academic year" do
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

      context "and an appropriate body has been setup for the second academic year" do
        before do
          sign_in_as school.induction_tutor

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                   .choose_academic_year(academic_year:)
                                                                   .start_add_appropriate_body_wizard
                                                                   .report_appropriate_body(appropriate_body:)

          sign_out
        end

        it_behaves_like "a school with an appropriate body record", start_year: 2022
        it_behaves_like "a school that can add a participant", start_year: 2022
      end
    end

    context "When they have setup a design your own induction programme for the second academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Wizards::SetupNextAcademicYearWizard.loaded
                                                              .choose_diy

        sign_out
      end

      it_behaves_like "a school with an associated school cohort record", start_year: 2022
      it_behaves_like "a school with a default diy induction programme record", start_year: 2022
      it_behaves_like "a school that cannot add a participant", start_year: 2022

      context "and an appropriate body has been setup for the second academic year" do
        before do
          sign_in_as school.induction_tutor

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
                                                                   .choose_academic_year(academic_year:)
                                                                   .start_add_appropriate_body_wizard
                                                                   .report_appropriate_body(appropriate_body:)

          sign_out
        end

        it_behaves_like "a school with an appropriate body record", start_year: 2022
        it_behaves_like "a school that cannot add a participant", start_year: 2022
      end
    end

    context "When they have reported no ECTs expected for the second academic year" do
      before do
        sign_in_as school.induction_tutor

        ::Pages::Schools::Wizards::SetupNextAcademicYearWizard.loaded
                                                              .choose_no_ects

        sign_out
      end

      it_behaves_like "a school with an associated school cohort record", start_year: 2022
      it_behaves_like "a school with no induction programme record", start_year: 2022
      it_behaves_like "a school that cannot add a participant", start_year: 2022
    end
  end
end
