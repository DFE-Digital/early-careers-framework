# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileState, :with_default_schedules, type: :model do
  let(:participant_profile) { create(:npq_participant_profile) }

  subject(:participant_profile_state) { create(:participant_profile_state, participant_profile:) }

  describe "associations" do
    it { is_expected.to belong_to(:participant_profile).touch(true) }
    it { is_expected.to belong_to(:cpd_lead_provider).optional }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:state).with_values(
        active: "active",
        deferred: "deferred",
        withdrawn: "withdrawn",
      ).backed_by_column_of_type(:text)
    }
  end

  describe "scopes" do
    describe ".most_recent" do
      let!(:another_participant_profile_state) { create(:participant_profile_state, participant_profile:) }

      before do
        participant_profile_state.update!(created_at: 2.weeks.ago)
      end

      it "fetches the most recent record only" do
        expect(described_class.most_recent).to eq([another_participant_profile_state])
      end
    end
  end
end
