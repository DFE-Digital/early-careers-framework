# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantEligibility, type: :model do
  let(:participant_profile) { create(:ect_participant_profile) }
  subject(:eligibility) { described_class.new(participant_profile:, active_flags: false, previous_participation: false, previous_induction: false, qts: true) }

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
      no_induction: "no_induction",
      exempt_from_induction: "exempt_from_induction",
      no_qts: "no_qts",
      different_trn: "different_trn",
      duplicate_profile: "duplicate_profile",
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
    context "when manually_validated is true" do
      it "does not determine a new status and reason" do
        eligibility.active_flags = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_active_flags_reason

        eligibility.status = :ineligible
        eligibility.manually_validated = true
        eligibility.determine_status
        expect(eligibility).to be_ineligible_status
        expect(eligibility).to be_active_flags_reason
      end
    end

    context "when active_flags are true" do
      it "sets the status to manual_check" do
        eligibility.active_flags = true
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
        expect(eligibility).to be_active_flags_reason
      end
    end

    context "when previous_participation is true" do
      it "sets the status to ineligible" do
        eligibility.previous_participation = true
        eligibility.valid?
        expect(eligibility).to be_ineligible_status
        expect(eligibility).to be_previous_participation_reason
      end
    end

    context "when previous_induction is true" do
      before do
        eligibility.previous_induction = true
        eligibility.valid?
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

    context "when QTS status is false and no other flags are set" do
      it "sets the status to manual_check" do
        eligibility.qts = false
        eligibility.valid?
        expect(eligibility).to be_manual_check_status
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

    context "when QTS status is false and the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile) }
      subject(:eligibility) { described_class.new(participant_profile:, active_flags: false, previous_participation: false, previous_induction: false, qts: true) }

      it "sets the status to eligible" do
        eligibility.qts = false
        eligibility.valid?
        expect(eligibility).to be_eligible_status
        expect(eligibility).to be_none_reason
      end
    end

    context "when no_induction is set to true" do
      context "the user is an ect" do
        it "sets the status to manual_check and reason as no_induction" do
          eligibility.no_induction = true
          eligibility.valid?
          expect(eligibility).to be_manual_check_status
          expect(eligibility).to be_no_induction_reason
        end
      end

      context "the user is a mentor" do
        let!(:participant_profile) { create(:mentor_participant_profile) }

        it "does not set the status to manual check" do
          eligibility.no_induction = true
          eligibility.valid?
          expect(eligibility).to be_eligible_status
        end
      end
    end

    context "when exempt_from_induction is set to true" do
      context "the user is an ect" do
        it "sets the status to ineligible" do
          eligibility.exempt_from_induction = true
          eligibility.valid?
          expect(eligibility).to be_ineligible_status
          expect(eligibility).to be_exempt_from_induction_reason
        end
      end

      context "the user is a mentor" do
        let!(:participant_profile) { create(:mentor_participant_profile) }

        it "does not set the status to ineligible" do
          eligibility.exempt_from_induction = true
          eligibility.valid?
          expect(eligibility).to be_eligible_status
        end
      end
    end
  end

  describe "#ineligible_but_not_duplicated_or_previously_participated?" do
    (described_class.statuses.keys - %w[ineligible]).each do |status|
      context "when the status is #{status}" do
        described_class.reasons.each_key do |reason|
          context "when the reason is #{reason}" do
            subject { described_class.new(status:, reason:) }

            it { is_expected.not_to be_ineligible_but_not_duplicated_or_previously_participated }
          end
        end
      end
    end

    context "when the status is ineligible" do
      let(:status) { :ineligible }

      (described_class.reasons.keys - %w[previous_participation duplicate_profile]).each do |reason|
        context "when the reason is #{reason}" do
          subject { described_class.new(status:, reason:) }

          it { is_expected.to be_ineligible_but_not_duplicated_or_previously_participated }
        end
      end

      %i[previous_participation duplicate_profile].each do |reason|
        context "when the reason is #{reason}" do
          subject { described_class.new(status:, reason:) }

          it { is_expected.not_to be_ineligible_but_not_duplicated_or_previously_participated }
        end
      end
    end
  end
end
