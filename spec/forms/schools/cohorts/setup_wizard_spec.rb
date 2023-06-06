# frozen_string_literal: true

RSpec.describe Schools::Cohorts::SetupWizard, type: :model do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:current_step) { :what_we_need }
  let(:data_store) { instance_double(FormData::CohortSetupStore) }
  let(:school) { create(:seed_school, :with_induction_coordinator) }
  let(:school_cohort) { create(:seed_school_cohort, :fip, cohort:, school:) }
  let(:sit_user) { school.induction_coordinators.first }
  let(:default_step_name) { :what_we_need }
  let(:submitted_params) { {} }
  let(:start_year) { cohort.start_year }

  subject(:wizard) { described_class.new(current_step:, data_store:, current_user: sit_user, default_step_name:, cohort:, school:, submitted_params:) }

  before do
    allow(data_store).to receive(:store).and_return({ something: "is here" })
    allow(data_store).to receive(:current_user).and_return(sit_user)
    allow(data_store).to receive(:school_id).and_return(school.slug)
    allow(data_store).to receive(:set)
    allow(data_store).to receive(:bulk_get).and_return({})
    allow(data_store).to receive(:clean)
    allow(data_store).to receive(:cohort_start_year).and_return(start_year)
  end

  shared_context "sending the pilot survey" do
    it "does not send the pilot survey" do
      expect {
        wizard.success
      }.not_to have_enqueued_mail(SchoolMailer, :cohortless_pilot_2023_survey_email)
    end

    context "when the school is in the pilot", with_feature_flag: { cohortless_dashboard: "active" }, travel_to: Date.new(2023, 7, 1) do
      it "sends the pilot survey" do
        expect {
          wizard.success
        }.not_to have_enqueued_mail(SchoolMailer, :cohortless_pilot_2023_survey_email)
      end
    end
  end

  describe "#success" do
    let(:expect_any_ects) { false }
    let(:keep_providers) { false }
    let(:what_changes) { nil }

    before do
      allow(wizard).to receive(:expect_any_ects?).and_return(expect_any_ects)
      allow(wizard).to receive(:keep_providers?).and_return(keep_providers)
      allow(wizard).to receive(:what_changes).and_return(what_changes)
    end

    context "when the SIT does not expect any ECTs" do
      it "does not send the pilot survey" do
        expect(wizard).to receive(:set_cohort_induction_programme!).with(:no_early_career_teachers, opt_out_of_updates: true)

        expect {
          wizard.success
        }.not_to have_enqueued_mail(SchoolMailer, :cohortless_pilot_2023_survey_email)
      end
    end

    context "when the SIT chooses to keep providers" do
      let(:expect_any_ects) { true }
      let(:keep_providers) { true }

      before do
        expect(wizard).to receive(:active_partnership?).and_return(true)
        expect(wizard).to receive(:save_appropriate_body).once
      end

      include_context "sending the pilot survey"
    end

    context "when the SIT chooses to keep providers" do
      let(:expect_any_ects) { true }
      let(:what_changes) { "change_lead_provider" }

      before do
        expect(wizard).to receive(:set_cohort_induction_programme!).with(:full_induction_programme)
        expect(wizard).to receive(:previously_fip_with_active_partnership?).and_return(false)
      end

      include_context "sending the pilot survey"
    end

    context "when the SIT chooses to change something" do
      let(:expect_any_ects) { true }
      let(:what_changes) { "change_lead_provider" }

      before do
        expect(wizard).to receive(:set_cohort_induction_programme!).with(:full_induction_programme)
        expect(wizard).to receive(:previously_fip_with_active_partnership?).and_return(false)
      end

      include_context "sending the pilot survey"
    end
  end
end
