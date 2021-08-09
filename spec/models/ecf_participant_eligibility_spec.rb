# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantEligibility, type: :model do
  subject(:eligibility) { described_class.new(active_flags: false, previous_participation: false, previous_induction: false, qts: true) }

  it { is_expected.to belong_to(:participant_profile) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      eligible: "eligible",
      matched: "matched",
      manual_check: "manual_check",
    ).backed_by_column_of_type(:string).with_suffix
  }

  it "updates the updated_at on the User" do
    freeze_time
    profile = create(:participant_profile, :ect)
    user = profile.user
    eligibility = profile.create_ecf_participant_eligibility!(qts: true, active_flags: false)
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
      end
    end

    context "when previous_participation is true" do
      it "sets the status to manual_check" do
        eligibility.previous_participation = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
      end
    end

    context "when previous_induction is true" do
      it "sets the status to manual_check" do
        eligibility.previous_induction = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
      end
    end

    context "when QTS status is false and no other flags are set" do
      it "sets the status to matched" do
        eligibility.qts = false
        eligibility.valid?
        expect(eligibility).to be_matched_status
      end
    end

    context "when QTS status is true and no other flags are set" do
      # NOTE: this is the holding pen functionality to make all requests
      # go via a manual validation until we have more supporting data
      # This scenario should set the status to :eligible otherwise
      it "sets the status to matched" do
        eligibility.qts = true
        eligibility.valid?
        expect(eligibility).to be_matched_status
      end
    end
  end
end
