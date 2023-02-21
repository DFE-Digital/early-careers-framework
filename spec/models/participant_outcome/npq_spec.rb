# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantOutcome::NPQ, :with_default_schedules, type: :model do
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }
  let(:declaration) { create :npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider }
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
    subject(:result) { described_class.to_send_to_qualified_teachers_api }

    context "when a declaration is not closed" do
      let!(:declaration) { create(:npq_participant_declaration, declaration_type: "started") }
      let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

      it { is_expected.to be_empty }
    end

    context "when a declaration is closed" do
      let!(:declaration) { create(:npq_participant_declaration, declaration_type: "completed") }

      context "when the latest outcome for a declaration has been sent to the qualified teachers API" do
        let!(:outcome_1) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_2) { create(:participant_outcome, :failed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }

        it { is_expected.to be_empty }
      end

      context "when the latest outcome for a declaration has not been sent to the qualified teachers API but a previous outcome has been sent" do
        let!(:outcome_1) { create(:participant_outcome, :passed, :sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_2) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
        let!(:outcome_3) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

        it { is_expected.not_to include(outcome_1) }
        it { is_expected.not_to include(outcome_2) }
        it { is_expected.to include(outcome_3) }
      end

      context "when no outcomes for a declaration have been sent to the qualified teachers API" do
        context "when the latest outcome is passed" do
          let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
          let!(:outcome_2) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
          let!(:outcome_3) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

          it { is_expected.not_to include(outcome_1) }
          it { is_expected.not_to include(outcome_2) }
          it { is_expected.to include(outcome_3) }
        end

        context "when the latest outcome is not passed" do
          let!(:outcome_1) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
          let!(:outcome_2) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }
          let!(:outcome_3) { create(:participant_outcome, :voided, :not_sent_to_qualified_teachers_api, participant_declaration: declaration) }

          it { is_expected.not_to include(outcome_1) }
          it { is_expected.not_to include(outcome_2) }
          it { is_expected.not_to include(outcome_3) }
        end
      end
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
end
