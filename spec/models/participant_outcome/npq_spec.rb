# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcome::NPQ, type: :model do
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let!(:cohort) { Cohort.find_by(start_year: Cohort.previous.start_year - 1) }
  let(:npq_application) { create :npq_application, :accepted, cohort:, npq_lead_provider: provider.npq_lead_provider }
  let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date + 1.day }
  let(:declaration) do
    travel_to declaration_date do
      create(:npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider, declaration_type: "completed", declaration_date:)
    end
  end
  subject(:outcome) { create :participant_outcome, participant_declaration: declaration }

  describe "associations" do
    it {
      is_expected.to belong_to(:participant_declaration)
        .class_name("ParticipantDeclaration::NPQ")
    }

    it "can be created/retrieved via declaration" do
      new_outcome = declaration.outcomes.create!(
        completion_date: Date.yesterday,
        state: "passed",
      )
      expect(declaration.reload.outcomes).to include(new_outcome)
    end

    it { is_expected.to have_many(:participant_outcome_api_requests) }
  end

  describe "state" do
    it {
      is_expected.to define_enum_for(:state).with_values(
        passed: "passed",
        failed: "failed",
        voided: "voided",
      ).backed_by_column_of_type(:string)
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:completion_date) }

    it "is valid with date < today" do
      outcome.completion_date = Date.yesterday
      expect(outcome.valid?).to eq(true)
    end

    it "is valid with date = today" do
      outcome.completion_date = Time.zone.today
      expect(outcome.valid?).to eq(true)
    end

    it "is invalid with date > today" do
      outcome.completion_date = Date.tomorrow
      aggregate_failures "future date" do
        expect(outcome.valid?).to eq(false)
        expect(outcome.errors[:completion_date].to_a).to eq(["The attribute '#/completion_date' cannot contain a future date. Resubmit the outcome update with a valid date."])
      end
    end

    %w[passed failed voided].each do |state|
      it "allows #{state} for `state`" do
        outcome.state = state
        expect(outcome.valid?).to eq(true)
      end
    end

    it "disallows anything else for state" do
      expect { outcome.state = "invalid" }.to raise_error(ArgumentError, "'invalid' is not a valid state")
      expect(outcome.valid?).to eq(true)
    end
  end

  describe "scopes" do
    describe "#latest" do
      let!(:outcome) { create(:participant_outcome, participant_declaration: declaration, created_at: 1.day.ago) }
      let!(:another_outcome) { create(:participant_outcome, participant_declaration: declaration) }

      it "returns the latest outcome only" do
        expect(described_class.latest).to eql(another_outcome)
      end
    end
  end

  describe ".to_send_to_qualified_teachers_api" do
    subject(:result) { described_class.to_send_to_qualified_teachers_api.map(&:id) }

    context "when the latest outcome for a declaration has been sent to the qualified teachers API" do
      let!(:outcome_1) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
      let!(:outcome_2) { create(:participant_outcome, :failed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }

      it { is_expected.to be_empty }
    end

    context "when the latest outcome for a declaration has not been sent to the qualified teachers API but a previous outcome has been sent" do
      let!(:outcome_1) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
      let!(:outcome_2) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
      let!(:outcome_3) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

      it { is_expected.not_to include(outcome_1.id, outcome_2.id) }
      it { is_expected.to include(outcome_3.id) }
    end

    context "when the latest outcome is sent but previous outcomes were not sent" do
      let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
      let!(:outcome_2) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
      let!(:outcome_3) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }

      it { is_expected.not_to include(outcome_1.id, outcome_2.id, outcome_3.id) }
    end

    context "when no outcomes for a declaration have been sent to the qualified teachers API" do
      context "when the latest outcome is passed" do
        let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_2) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_3) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

        it { is_expected.not_to include(outcome_1.id, outcome_2.id) }
        it { is_expected.to include(outcome_3.id) }
      end

      context "when the latest outcome is not passed" do
        let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_2) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_3) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

        it { is_expected.not_to include(outcome_1.id, outcome_2.id, outcome_3.id) }
      end
    end

    describe ".sent_to_qualified_teachers_api" do
      let!(:outcome_1) { create(:participant_outcome, :sent_to_qualified_teachers_api) }
      let!(:outcome_2) { create(:participant_outcome, :not_sent_to_qualified_teachers_api) }

      subject(:result) { described_class.sent_to_qualified_teachers_api.map(&:id) }

      it { is_expected.to include(outcome_1.id) }
      it { is_expected.not_to include(outcome_2.id) }
    end

    describe ".not_sent_to_qualified_teachers_api" do
      let!(:outcome_1) { create(:participant_outcome, :sent_to_qualified_teachers_api) }
      let!(:outcome_2) { create(:participant_outcome, :not_sent_to_qualified_teachers_api) }

      subject(:result) { described_class.not_sent_to_qualified_teachers_api.map(&:id) }

      it { is_expected.to include(outcome_2.id) }
      it { is_expected.not_to include(outcome_1.id) }
    end

    describe ".passed" do
      let!(:outcome_1) { create(:participant_outcome, :passed) }
      let!(:outcome_2) { create(:participant_outcome, :failed) }

      subject(:result) { described_class.passed.map(&:id) }

      it { is_expected.to include(outcome_1.id) }
      it { is_expected.not_to include(outcome_2.id) }
    end

    describe ".not_passed" do
      let!(:outcome_1) { create(:participant_outcome, :passed) }
      let!(:outcome_2) { create(:participant_outcome, :failed) }

      subject(:result) { described_class.not_passed.map(&:id) }

      it { is_expected.to include(outcome_2.id) }
      it { is_expected.not_to include(outcome_1.id) }
    end

    describe ".declarations_where_outcome_passed_and_sent" do
      let(:npq_application_1) { create :npq_application, :accepted, cohort:, npq_lead_provider: provider.npq_lead_provider }
      let(:declaration_date_1) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date + 1.day }
      let(:npq_application_2) { create :npq_application, :accepted, cohort:, npq_lead_provider: provider.npq_lead_provider }
      let(:declaration_date_2) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date + 1.day }
      let!(:declaration_1) do
        travel_to declaration_date_1 do
          create(:npq_participant_declaration, participant_profile: npq_application_1.profile, cpd_lead_provider: provider, declaration_type: "completed")
        end
      end
      let!(:declaration_2) do
        travel_to declaration_date_2 do
          create(:npq_participant_declaration, participant_profile: npq_application_2.profile, cpd_lead_provider: provider, declaration_type: "completed")
        end
      end
      let!(:outcome_1) { create(:participant_outcome, :failed, :sent_to_qualified_teachers_api, participant_declaration: declaration_1) }
      let!(:outcome_2) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration_2) }
      let!(:outcome_3) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration_2) }
      let!(:outcome_4) { create(:participant_outcome, :voided, :sent_to_qualified_teachers_api, participant_declaration: declaration_2) }

      subject(:result) { described_class.declarations_where_outcome_passed_and_sent }

      it { is_expected.not_to include(declaration_1.id) }
      it { is_expected.to include(declaration_2.id) }
    end

    describe ".latest_per_declaration" do
      let(:npq_application_1) { create :npq_application, :accepted, cohort:, npq_lead_provider: provider.npq_lead_provider }
      let(:declaration_date_1) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date + 1.day }
      let(:npq_application_2) { create :npq_application, :accepted, cohort:, npq_lead_provider: provider.npq_lead_provider }
      let(:declaration_date_2) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date + 1.day }
      let!(:declaration_1) do
        travel_to declaration_date_1 do
          create(:npq_participant_declaration, participant_profile: npq_application_1.profile, cpd_lead_provider: provider, declaration_type: "completed")
        end
      end
      let!(:declaration_2) do
        travel_to declaration_date_2 do
          create(:npq_participant_declaration, participant_profile: npq_application_2.profile, cpd_lead_provider: provider, declaration_type: "completed")
        end
      end
      let!(:outcome_1) { create(:participant_outcome, participant_declaration: declaration_1, created_at: 1.day.ago) }
      let!(:outcome_2) { create(:participant_outcome, participant_declaration: declaration_1) }
      let!(:outcome_3) { create(:participant_outcome, participant_declaration: declaration_2) }

      subject(:result) { described_class.latest_per_declaration.map(&:id) }

      it { is_expected.to include(outcome_2.id, outcome_3.id) }
      it { is_expected.not_to include(outcome_1.id) }
    end
  end

  describe ".has_passed?" do
    it "returns true if passed" do
      outcome = described_class.new(state: "passed")
      expect(outcome.has_passed?).to eql(true)
    end

    it "returns false if failed" do
      outcome = described_class.new(state: "failed")
      expect(outcome.has_passed?).to eql(false)
    end

    it "returns nil if voided" do
      outcome = described_class.new(state: "voided")
      expect(outcome.has_passed?).to eql(nil)
    end
  end

  describe "#push_outcome_to_big_query" do
    context "on create" do
      it "pushes outcome to BigQuery" do
        allow(ParticipantOutcomes::StreamBigQueryJob).to receive(:perform_later).and_call_original
        outcome
        expect(ParticipantOutcomes::StreamBigQueryJob).to have_received(:perform_later).with(participant_outcome_id: outcome.id)
      end
    end

    context "on update" do
      it "pushes outcome to BigQuery" do
        allow(ParticipantOutcomes::StreamBigQueryJob).to receive(:perform_later).and_call_original
        outcome
        outcome.update!(state: "voided")
        expect(ParticipantOutcomes::StreamBigQueryJob).to have_received(:perform_later).with(participant_outcome_id: outcome.id).twice
      end
    end
  end

  describe "#has_failed?" do
    it "returns true if failed" do
      outcome = described_class.new(state: "failed")
      expect(outcome.has_failed?).to eql(true)
    end

    it "returns false if passed" do
      outcome = described_class.new(state: "passed")
      expect(outcome.has_failed?).to eql(false)
    end

    it "returns nil if voided" do
      outcome = described_class.new(state: "voided")
      expect(outcome.has_failed?).to eql(nil)
    end
  end

  describe "#passed_but_not_sent?" do
    it "returns true if passed but not sent" do
      outcome = described_class.new(state: "passed", sent_to_qualified_teachers_api_at: nil)
      expect(outcome.passed_but_not_sent?).to eql(true)
    end

    it "returns false if passed and sent" do
      outcome = described_class.new(state: "passed", sent_to_qualified_teachers_api_at: Time.zone.now)
      expect(outcome.passed_but_not_sent?).to eql(false)
    end

    it "returns false if failed" do
      outcome = described_class.new(state: "failed", sent_to_qualified_teachers_api_at: nil)
      expect(outcome.passed_but_not_sent?).to eql(false)
    end
  end

  describe "#failed_but_not_sent?" do
    it "returns true if failed but not sent" do
      outcome = described_class.new(state: "failed", sent_to_qualified_teachers_api_at: nil)
      expect(outcome.failed_but_not_sent?).to eql(true)
    end

    it "returns false if failed and sent" do
      outcome = described_class.new(state: "failed", sent_to_qualified_teachers_api_at: Time.zone.now)
      expect(outcome.failed_but_not_sent?).to eql(false)
    end

    it "returns false if passed" do
      outcome = described_class.new(state: "passed", sent_to_qualified_teachers_api_at: nil)
      expect(outcome.failed_but_not_sent?).to eql(false)
    end
  end

  describe "#passed_and_recorded?" do
    it "returns true if passed and recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.passed_and_recorded?).to eql(true)
    end

    it "returns false if passed but not recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.passed_and_recorded?).to eql(false)
    end

    it "returns false if failed and recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.passed_and_recorded?).to eql(false)
    end

    it "returns false if failed but not recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.passed_and_recorded?).to eql(false)
    end
  end

  describe "#failed_and_recorded?" do
    it "returns true if failed and recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.failed_and_recorded?).to eql(true)
    end

    it "returns false if failed but not recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.failed_and_recorded?).to eql(false)
    end

    it "returns false if passed and recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.failed_and_recorded?).to eql(false)
    end

    it "returns false if passed but not recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.failed_and_recorded?).to eql(false)
    end
  end

  describe "#passed_but_not_recorded?" do
    it "returns true if passed but not recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: false,
      )
      expect(outcome.passed_but_not_recorded?).to eql(true)
    end

    it "returns false if passed and recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.passed_but_not_recorded?).to eql(false)
    end

    it "returns false if failed and recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.passed_but_not_recorded?).to eql(false)
    end

    it "returns false if failed but not recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.passed_but_not_recorded?).to eql(false)
    end
  end

  describe "#failed_but_not_recorded?" do
    it "returns true if failed but not recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: false,
      )
      expect(outcome.failed_but_not_recorded?).to eql(true)
    end

    it "returns false if failed and recorded" do
      outcome = described_class.new(
        state: "failed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.failed_but_not_recorded?).to eql(false)
    end

    it "returns false if passed and recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: Time.zone.now,
        qualified_teachers_api_request_successful: true,
      )
      expect(outcome.failed_but_not_recorded?).to eql(false)
    end

    it "returns false if passed but not recorded" do
      outcome = described_class.new(
        state: "passed",
        sent_to_qualified_teachers_api_at: nil,
        qualified_teachers_api_request_successful: nil,
      )
      expect(outcome.failed_but_not_recorded?).to eql(false)
    end
  end

  describe "#resend!" do
    let(:resend_service_instance) { double }

    before do
      allow(NPQ::ResendParticipantOutcome).to receive(:new).and_return(resend_service_instance)
    end

    it "calls the correct service class" do
      expect(NPQ::ResendParticipantOutcome).to receive(:new).with(participant_outcome_id: subject.id).and_return(resend_service_instance)
      expect(resend_service_instance).to receive(:call)

      outcome.resend!
    end
  end

  describe "#latest_per_declaration?" do
    let!(:outcome_1) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
    let!(:outcome_2) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
    let!(:outcome_3) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
    let!(:outcome_4) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api) }

    it "checks whether an outcome is the latest participant outcome for a declaration or not " do
      expect(outcome_1.latest_per_declaration?).to be_falsey
      expect(outcome_2.latest_per_declaration?).to be_falsey
      expect(outcome_3.latest_per_declaration?).to be_truthy
      expect(outcome_4.latest_per_declaration?).to be_truthy
    end
  end
end
