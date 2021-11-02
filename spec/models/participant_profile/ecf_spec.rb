# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::ECF, type: :model do
  let(:profile) { create(:participant_profile, :ecf) }

  describe ":current_cohort" do
    let!(:cohort_2020) { create(:cohort, start_year: 2020) }
    let!(:current_cohort) { create(:cohort, :current) }
    let!(:participant_2020) { create(:participant_profile, :ecf, school_cohort: create(:school_cohort, cohort: cohort_2020)) }
    let!(:current_participant) { create(:participant_profile, :ecf, school_cohort: create(:school_cohort, cohort: current_cohort)) }

    it "does not include 2020 participants" do
      expect(ParticipantProfile::ECF.current_cohort).not_to include(participant_2020)
    end

    it "includes participants from the current cohort" do
      expect(ParticipantProfile::ECF.current_cohort).to include(current_participant)
      expect(ParticipantProfile::ECF.current_cohort.count).to eql 1
    end
  end

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

  describe "details_being_checked" do
    let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: profile) }
    context "when the details have not been matched" do
      it "returns the profile" do
        expect(ParticipantProfile::ECF.details_being_checked).to match_array([profile])
      end
    end
    context "when the eligibility is manual check" do
      let!(:eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile: profile) }
      it "returns the profile" do
        expect(ParticipantProfile::ECF.details_being_checked).to match_array([profile])
      end
    end
  end
end
