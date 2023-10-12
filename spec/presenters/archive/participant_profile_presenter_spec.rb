# frozen_string_literal: true

require "rails_helper"

RSpec.describe Archive::ParticipantProfilePresenter do
  include ArchiveHelper

  let(:profile) { create(:seed_ect_participant_profile, :valid) }

  # let(:id) { SecureRandom.uuid }
  # let(:alt_id) { SecureRandom.uuid }
  # let(:profile_id) { SecureRandom.uuid }
  # let(:trn) { "0012345" }
  # let(:user) { build_archived_ect(name: "Adam West", id:, alt_id:, profile_id:, trn:) }
  # let(:profile) { user.data.dig("attributes", "participant_profiles").first }
  let(:serialized_profile) { JSON.parse(Archive::ParticipantProfileSerializer.new(profile).serializable_hash[:data].to_json) }
  subject(:presenter) { described_class.new(serialized_profile) }

  describe "#ecf?" do
    it "returns true when the profile is ECF" do
      expect(presenter).to be_ecf
    end

    context "when the profile is NPQ" do
      let(:profile) { create(:seed_npq_participant_profile, :valid) }
      it "returns false" do
        expect(presenter).not_to be_ecf
      end
    end
  end

  describe "#sparsity_uplift?" do
    it "reflects the original sparsity uplift flag" do
      expect(presenter.sparsity_uplift?).to eq profile.sparsity_uplift?
    end
  end

  describe "#pupil_premium_uplift?" do
    it "reflects the original pupil premium uplift flag" do
      expect(presenter.pupil_premium_uplift?).to eq profile.pupil_premium_uplift?
    end
  end

  describe "#school_cohort" do
    it "returns the original school_cohort" do
      expect(presenter.school_cohort).to eq profile.school_cohort
    end
  end

  describe "#schedule" do
    it "returns the original schedule" do
      expect(presenter.schedule).to eq profile.schedule
    end
  end

  describe "#created_at" do
    it "returns the user creation date" do
      expect(presenter.created_at).to be_within(1.second).of profile.created_at
    end
  end
end
