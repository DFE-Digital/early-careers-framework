# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDeclarationOutcome, :with_default_schedules, type: :model do
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
