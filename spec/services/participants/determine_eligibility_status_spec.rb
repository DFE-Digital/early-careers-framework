# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::DetermineEligibilityStatus do
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }
  let(:save_record) { true }
  let(:force_validation) { false }
  subject(:service_call) { described_class.call(ecf_participant_eligibility: eligibility, save_record:, force_validation:) }

  describe "#call" do
    context "when manually_validated is true" do
      before do
        eligibility.status = :manual_check
        eligibility.reason = :active_flags
        eligibility.manually_validated = true
        eligibility.save!
        service_call
      end

      it "does not determine a new status and reason" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_active_flags_reason
      end

      context "when the force_validation param is set" do
        let(:force_validation) { true }

        it "determines a new status and reason" do
          expect(eligibility).to be_eligible_status
          expect(eligibility).to be_none_reason
        end

        it "clears the manually_validated flag" do
          expect(eligibility).not_to be_manually_validated
        end
      end
    end

    context "when save_record is false" do
      let(:save_record) { false }

      before do
        eligibility.active_flags = true
        service_call
      end

      it "does not persist the changes" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility.reload).to be_eligible_status
      end
    end

    context "when active_flags are true" do
      before do
        eligibility.active_flags = true
        service_call
      end

      it "sets the status to manual_check" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_active_flags_reason
      end
    end

    context "when previous_participation is true" do
      before do
        eligibility.previous_participation = true
        service_call
      end

      it "sets the status to ineligible" do
        expect(eligibility).to be_ineligible_status
        expect(eligibility).to be_previous_participation_reason
      end
    end

    context "when previous_induction is true" do
      before do
        eligibility.previous_induction = true
        service_call
      end

      it "sets the status to ineligible" do
        expect(eligibility).to be_ineligible_status
        expect(eligibility).to be_previous_induction_reason
      end

      context "when participant is a mentor" do
        let!(:participant_profile) { create(:mentor_participant_profile) }

        it "does not consider the previous_induction flag" do
          expect(eligibility).to be_eligible_status
          expect(eligibility).to be_none_reason
        end
      end
    end

    context "when different_trn is true" do
      before do
        eligibility.different_trn = true
        service_call
      end

      it "sets the status to manual_check" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_different_trn_reason
      end
    end

    context "when profile is a secondary mentor profile" do
      let!(:participant_profile) { create(:mentor_participant_profile, profile_duplicity: :secondary) }

      before do
        service_call
      end

      it "sets the status to ineligible" do
        expect(eligibility).to be_ineligible_status
        expect(eligibility).to be_duplicate_profile_reason
      end
    end

    context "when QTS status is false and no other flags are set" do
      before do
        eligibility.qts = false
        service_call
      end

      it "sets the status to manual_check" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_no_qts_reason
      end
    end

    context "when QTS status is true and no other flags are set" do
      before do
        eligibility.qts = true
        service_call
      end

      it "sets the status to eligible" do
        expect(eligibility).to be_eligible_status
        expect(eligibility).to be_none_reason
      end
    end

    context "when QTS status is false and the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile) }

      before do
        eligibility.qts = false
        service_call
      end

      it "sets the status to eligible" do
        expect(eligibility).to be_eligible_status
        expect(eligibility).to be_none_reason
      end
    end

    context "when no_induction is set to true" do
      before do
        eligibility.no_induction = true
        service_call
      end

      context "the user is an ect" do
        it "sets the status to manual_check and reason as no_induction" do
          expect(eligibility).to be_manual_check_status
          expect(eligibility).to be_no_induction_reason
        end
      end

      context "the user is a mentor" do
        let!(:participant_profile) { create(:mentor_participant_profile) }

        it "does not set the status to manual check" do
          expect(eligibility).to be_eligible_status
        end
      end
    end

    context "when exempt_from_induction is set to true" do
      before do
        eligibility.exempt_from_induction = true
        service_call
      end

      context "the user is an ect" do
        it "sets the status to ineligible" do
          expect(eligibility).to be_ineligible_status
          expect(eligibility).to be_exempt_from_induction_reason
        end
      end

      context "the user is a mentor" do
        let!(:participant_profile) { create(:mentor_participant_profile) }

        it "does not set the status to ineligible" do
          expect(eligibility).to be_eligible_status
        end
      end
    end
  end
end
