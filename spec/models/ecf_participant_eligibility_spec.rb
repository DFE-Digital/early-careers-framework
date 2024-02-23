# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantEligibility, type: :model do
  let(:participant_profile) { create(:ect_participant_profile) }
  subject(:eligibility) { described_class.new(participant_profile:, active_flags: false, previous_participation: false, previous_induction: false, qts: true) }

  it { is_expected.to validate_presence_of :status }
  it { is_expected.to validate_presence_of :reason }
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

  describe ".waiting_for_induction scope" do
    let(:status) { :manual_check }
    let(:reason) { :no_induction }
    let!(:eligibility) { create(:seed_ecf_participant_eligibility, :with_participant_profile, status:, reason:) }

    it "returns records that would be valid if they had an induction registered" do
      expect(described_class.waiting_for_induction).to match_array [eligibility]
    end

    context "when the status is not manual_check" do
      it "does not return awaiting induction records" do
        described_class.statuses.except(:manual_check).each_value do |status|
          eligibility.update!(status:)
          expect(described_class.waiting_for_induction).not_to include eligibility
        end
      end
    end

    context "when the reason is not no_induction" do
      it "does not return awaiting induction records" do
        described_class.reasons.except(:no_induction).each_value do |reason|
          eligibility.update!(reason:)
          expect(described_class.waiting_for_induction).not_to include eligibility
        end
      end
    end
  end
end
