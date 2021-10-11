# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantEligibility, type: :model do
  let(:participant_profile) { create(:participant_profile, :ect) }
  subject(:eligibility) { described_class.new(participant_profile: participant_profile, active_flags: false, previous_participation: false, previous_induction: false, qts: true) }

  it { is_expected.to belong_to(:participant_profile) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      eligible: "eligible",
      matched: "matched",
      manual_check: "manual_check",
      ineligible: "ineligible",
    ).backed_by_column_of_type(:string).with_suffix
  }

  it {
    is_expected.to define_enum_for(:reason).with_values(
      active_flags: "active_flags",
      previous_participation: "previous_participation",
      previous_induction: "previous_induction",
      no_qts: "no_qts",
      different_trn: "different_trn",
      none: "none",
    ).backed_by_column_of_type(:string).with_suffix
  }

  it "updates the updated_at on the User" do
    freeze_time
    user = participant_profile.user
    eligibility.save!
    user.update!(updated_at: 2.weeks.ago)
    eligibility.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  describe "#determine_status" do
    context "when active_flags are true" do
      it "sets the status to manual_check" do
        eligibility.active_flags = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_active_flags_reason
      end
    end

    context "when previous_participation is true" do
      it "sets the status to manual_check" do
        eligibility.previous_participation = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_previous_participation_reason
      end
    end

    context "when previous_induction is true" do
      before do
        eligibility.previous_induction = true
        eligibility.valid?
      end

      it "sets the status to manual_check" do
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_previous_induction_reason
      end

      context "when participant is a mentor" do
        let!(:participant_profile) { create(:participant_profile, :mentor) }

        it "does not consider the previous_induction flag" do
          expect(eligibility).to be_eligible_status
          expect(eligibility).to be_none_reason
        end
      end
    end

    context "when QTS status is false and no other flags are set" do
      it "sets the status to matched" do
        eligibility.qts = false
        eligibility.valid?
        expect(eligibility).to be_matched_status
        expect(eligibility).to be_no_qts_reason
      end
    end

    context "when QTS status is true and no other flags are set" do
      it "sets the status to eligible" do
        eligibility.qts = true
        eligibility.valid?
        expect(eligibility).to be_eligible_status
        expect(eligibility).to be_none_reason
      end
    end
  end
end
