# frozen_string_literal: true

RSpec.describe Schools::Cohorts::SetupWizard, type: :model do
  let(:cohort) { Cohort.active_registration_cohort }
  let(:previous_cohort) { Cohort.find_or_create_by!(start_year: cohort.start_year - 1) }
  let(:current_step) { :what_we_need }
  let(:data_store) { instance_double(FormData::CohortSetupStore) }
  let(:school) { create(:seed_school, :with_induction_coordinator) }
  let(:school_cohort) { create(:seed_school_cohort, :fip, cohort:, school:) }
  let(:sit_user) { school.induction_coordinators.first }
  let(:default_step_name) { :what_we_need }
  let(:submitted_params) { {} }
  let(:start_year) { cohort.start_year }

  subject(:wizard) do
    described_class.new(current_step:,
                        data_store:,
                        current_user: sit_user,
                        default_step_name:,
                        cohort:,
                        school:,
                        submitted_params:)
  end

  before do
    allow(data_store).to receive(:store).and_return({ something: "is here" })
    allow(data_store).to receive(:current_user).and_return(sit_user)
    allow(data_store).to receive(:school_id).and_return(school.slug)
    allow(data_store).to receive(:set)
    allow(data_store).to receive(:bulk_get).and_return({})
    allow(data_store).to receive(:clean)
    allow(data_store).to receive(:cohort_start_year).and_return(start_year)
    allow(data_store).to receive(:appropriate_body_id).and_return(3)
    allow(data_store).to receive(:appropriate_body_appointed?).and_return(true)
  end

  # FIXME: removing while decision is made whether to keep/update/remove the survey for 2024
  # shared_context "sending the pilot survey" do
  #   context "when the school is in the pilot", travel_to: Date.new(2023, 7, 1) do
  #     it "sends the pilot survey" do
  #       expect {
  #         wizard.success
  #       }.to have_enqueued_mail(SchoolMailer, :cohortless_pilot_2023_survey_email)
  #     end
  #   end
  # end

  describe "#success" do
    let(:expect_any_ects) { false }
    let(:keep_providers) { false }
    let(:what_changes) { nil }

    before do
      allow(wizard).to receive(:expect_any_ects?).and_return(expect_any_ects)
      allow(wizard).to receive(:keep_providers?).and_return(keep_providers)
      allow(wizard).to receive(:what_changes).and_return(what_changes)
    end

    # FIXME: removing while decision is made whether to keep/update/remove the survey for 2024
    # context "when the SIT does not expect any ECTs" do
    #   it "does not send the pilot survey" do
    #     expect(Induction::SetCohortInductionProgramme)
    #       .to receive(:call).with(programme_choice: :no_early_career_teachers,
    #                               school_cohort:,
    #                               opt_out_of_updates: true,
    #                               delivery_partner_to_be_confirmed: false)
    #     expect(Induction::SetSchoolCohortAppropriateBody)
    #       .to receive(:call).with(school_cohort:,
    #                               appropriate_body_id: 3,
    #                               appropriate_body_appointed: true)
    #     expect {
    #       wizard.success
    #     }.not_to have_enqueued_mail(SchoolMailer, :cohortless_pilot_2023_survey_email)
    #   end
    # end

    context "when the SIT chooses to keep providers" do
      let(:expect_any_ects) { true }
      let(:keep_providers) { true }

      before do
        expect(wizard).to receive(:active_partnership?).and_return(true)
        expect(Induction::SetSchoolCohortAppropriateBody)
          .to receive(:call).with(school_cohort:,
                                  appropriate_body_id: 3,
                                  appropriate_body_appointed: true)
      end

      # include_context "sending the pilot survey"
    end

    context "when the SIT chooses to keep providers" do
      let(:expect_any_ects) { true }
      let(:keep_providers) { true }

      before do
        allow(wizard).to receive(:active_partnership?).and_return(false)
        NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: previous_cohort, school:)
                                               .build
                                               .with_programme
        expect(Induction::SetCohortInductionProgramme)
          .to receive(:call).with(programme_choice: :full_induction_programme,
                                  school_cohort:,
                                  opt_out_of_updates: false,
                                  delivery_partner_to_be_confirmed: false)
        expect(Induction::SetSchoolCohortAppropriateBody)
          .to receive(:call).with(school_cohort:,
                                  appropriate_body_id: 3,
                                  appropriate_body_appointed: true)
      end

      # include_context "sending the pilot survey"
    end

    context "when the SIT chooses to change something" do
      let(:expect_any_ects) { true }
      let(:what_changes) { "change_lead_provider" }

      before do
        expect(wizard).to receive(:set_cohort_induction_programme!).with(:full_induction_programme)
        expect(wizard).to receive(:previously_fip?).and_return(false)
      end

      # include_context "sending the pilot survey"
    end

    context "when the SIT chooses to change something" do
      let(:expect_any_ects) { true }
      let(:what_changes) { "change_lead_provider" }

      before do
        expect(Induction::SetCohortInductionProgramme)
          .to receive(:call).with(programme_choice: :full_induction_programme,
                                  school_cohort:,
                                  opt_out_of_updates: false,
                                  delivery_partner_to_be_confirmed: false)
        expect(Induction::SetSchoolCohortAppropriateBody)
          .to receive(:call).with(school_cohort:,
                                  appropriate_body_id: 3,
                                  appropriate_body_appointed: true)
      end

      context "when the previous programme was not fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(false)
        end

        it "do not notify any provider" do
          expect {
            wizard.success
          }.not_to have_enqueued_mail(LeadProviderMailer, :programme_changed_email)
        end
      end

      context "when the previous provider do not provides training this year" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(true)
          NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: previous_cohort, school:)
                                                 .build
                                                 .with_programme
        end

        it "do not notify any provider" do
          expect {
            wizard.success
          }.not_to have_enqueued_mail(LeadProviderMailer, :programme_changed_email)
        end
      end

      context "when the previous provider still provides training this year" do
        let(:old_school_cohort) do
          NewSeeds::Scenarios::SchoolCohorts::Fip.new(cohort: previous_cohort, school:)
                                                 .build
                                                 .with_programme
                                                 .school_cohort
        end
        let(:lead_provider) { old_school_cohort.default_induction_programme.lead_provider }
        let(:delivery_partner) { old_school_cohort.default_induction_programme.delivery_partner }

        before do
          allow(wizard).to receive(:previously_fip?).and_return(true)
          ProviderRelationship.create!(lead_provider:, delivery_partner:, cohort:)
          lead_provider.users.create!(email: "any@example.com", full_name: "Any surname")
        end

        it "notify the old provider" do
          expect {
            wizard.success
          }.to have_enqueued_mail(LeadProviderMailer, :programme_changed_email)
        end
      end

      # include_context "sending the pilot survey"
    end
  end

  describe "#previous_partnership_exists?" do
    context "when the previous cohort has an active partnership with a lead provider and a delivery partnern" do
      it "returns true" do
        allow(wizard).to receive(:previous_delivery_partner).and_return(true)
        allow(wizard).to receive(:previous_lead_provider).and_return(true)

        expect(wizard.previous_partnership_exists?).to be true
      end
    end

    context "when the previous cohort does not have an active partnership" do
      it "returns false" do
        allow(wizard).to receive(:previous_delivery_partner).and_return(false)
        allow(wizard).to receive(:previous_lead_provider).and_return(false)

        expect(wizard.previous_partnership_exists?).to be false
      end
    end
  end
end
