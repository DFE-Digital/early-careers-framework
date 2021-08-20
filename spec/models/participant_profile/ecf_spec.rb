# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::ECF, type: :model do
  let(:profile) { create(:participant_profile, :ecf) }

  describe "completed_validation_wizard?" do
    context "before any details have been entered" do
      it "returns false" do
        expect(profile.completed_validation_wizard?).to be false
      end
    end

    context "when the details have not been matched" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      it "returns true" do
        expect(profile.completed_validation_wizard?).to be true
      end
    end

    context "when the details have been matched" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }
      let!(:eligibility) { ECFParticipantEligibility.create!(participant_profile: profile) }

      it "returns true" do
        expect(profile.completed_validation_wizard?).to be true
      end
    end
  end

  describe "manual_check_needed?" do
    context "before any details have been entered" do
      it "returns false" do
        expect(profile.manual_check_needed?).to be false
      end
    end

    context "when the details have not been matched" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }

      it "returns true" do
        expect(profile.manual_check_needed?).to be true
      end
    end

    context "when the eligibility is matched" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }
      before do
        eligibility = ECFParticipantEligibility.create!(participant_profile: profile)
        eligibility.matched_status!
      end

      it "returns false" do
        expect(profile.manual_check_needed?).to be false
      end
    end

    context "when the eligibility is eligible" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }
      before do
        eligibility = ECFParticipantEligibility.create!(participant_profile: profile)
        eligibility.eligible_status!
      end

      it "returns false" do
        expect(profile.manual_check_needed?).to be false
      end
    end

    context "when the eligibility is manual check" do
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }
      before do
        eligibility = ECFParticipantEligibility.create!(participant_profile: profile)
        eligibility.manual_check_status!
      end

      it "returns true" do
        expect(profile.manual_check_needed?).to be true
      end
    end
  end
end
