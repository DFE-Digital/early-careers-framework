# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::ECF, type: :model do
  let(:profile) { create(:ecf_participant_profile) }

  describe ":current_cohort" do
    let!(:cohort_2020) { create(:cohort, start_year: 2020) }
    let!(:current_cohort) { create(:cohort, :current) }
    let!(:participant_2020) { create(:ecf_participant_profile, school_cohort: create(:school_cohort, cohort: cohort_2020)) }
    let!(:current_participant) { create(:ecf_participant_profile, school_cohort: create(:school_cohort, cohort: current_cohort)) }

    it "does not include 2020 participants" do
      expect(ParticipantProfile::ECF.current_cohort).not_to include(participant_2020)
    end

    it "includes participants from the current cohort" do
      expect(ParticipantProfile::ECF.current_cohort).to include(current_participant)
      expect(ParticipantProfile::ECF.current_cohort.count).to eql 1
    end
  end

  describe "after_update" do
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: profile.school_cohort) }
    let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile: profile, induction_status: "active") }

    context "when the status changes" do
      it "updates the status on the active induction record" do
        profile.withdrawn_record!
        expect(induction_record.reload).to be_withdrawn_induction_status
      end
    end

    context "when the status has not changed" do
      before { induction_record.completed_induction_status! }

      it "does not update the status" do
        profile.primary_profile!
        expect(induction_record.reload).to be_completed_induction_status
      end
    end

    context "when the training_status has not changed" do
      before { induction_record.training_status_deferred! }

      it "does not update the training_status" do
        profile.primary_profile!
        expect(induction_record.reload).to be_training_status_deferred
      end
    end
  end

  describe "contacted_for_info?" do
    context "when no ecf_participant_validation_data exists" do
      it "returns true" do
        expect(profile.contacted_for_info?).to be_truthy
      end
    end

    context "when ecf_participant_validation_data exists" do
      before do
        create(:ecf_participant_validation_data, participant_profile: profile)
      end

      it "returns false" do
        expect(profile.contacted_for_info?).to be_falsey
      end
    end
  end

  describe "current_induction_record" do
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: profile.school_cohort) }

    context "when no induction record exists" do
      it "returns nil" do
        expect(profile.current_induction_record).to be_nil
      end
    end

    context "when an induction record exists but it is not at active status" do
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile: profile, induction_status: "completed") }

      it "returns nil" do
        expect(profile.current_induction_record).to be_nil
      end
    end

    context "when an active induction record exists with an end_date in the past" do
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile: profile, induction_status: "active", end_date: 2.days.ago) }

      it "returns nil" do
        expect(profile.current_induction_record).to be_nil
      end
    end

    context "when an active induction record exists with an end_date in the future" do
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile: profile, induction_status: "active", end_date: 2.days.from_now) }

      it "returns the induction record" do
        expect(profile.current_induction_record).to eq induction_record
      end
    end

    context "when an active induction record exists with a start_date in the future" do
      let!(:induction_record) { Induction::Enrol.call(participant_profile: profile, induction_programme:, start_date: 2.days.from_now) }

      it "returns the induction record" do
        expect(profile.current_induction_record).to eq induction_record
      end

      context "when this is a school transfer" do
        let!(:induction_record) { Induction::Enrol.call(participant_profile: profile, induction_programme:, start_date: 2.days.from_now, school_transfer: true) }

        it "returns nil" do
          expect(profile.current_induction_record).to be_nil
        end
      end
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
