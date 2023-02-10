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
end
