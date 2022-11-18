# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclaration::Outcome::NPQ, :with_default_schedules, type: :model do
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }
  let(:declaration) { create :npq_participant_declaration, participant_profile: npq_application.profile, cpd_lead_provider: provider }
  let(:valid_params) do
    {
      participant_declaration: declaration,
      completion_date: Date.yesterday,
      state: "passed",
    }
  end

  describe "associations" do
    subject { described_class.new(valid_params) }

    it { is_expected.to belong_to(:participant_declaration) }
  end

  describe "state" do
    subject { described_class.new(valid_params) }

    it {
      is_expected.to define_enum_for(:state).with_values(
        passed: "passed",
        failed: "failed",
        voided: "voided",
      ).backed_by_column_of_type(:string)
    }
  end

  describe "validations" do
    subject(:outcome) { described_class.new(valid_params) }

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
        expect(outcome.errors[:completion_date].to_a).to eq(["Cannot be in the future"])
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
end
