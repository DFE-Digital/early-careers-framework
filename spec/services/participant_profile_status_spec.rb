# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfileStatus, :with_training_record_state_examples do
  describe "#initialize" do
    let(:participant_profile) { create(:ect_participant_profile) }
    let!(:induction_record) { create(:induction_record, participant_profile:) }

    subject { described_class.new(participant_profile:, induction_record:) }

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@participant_profile)).to eq(participant_profile)
    end

    it "sets it to the injected params if provided" do
      expect(subject.instance_variable_get(:@induction_record)).to eq(induction_record)
    end
  end

  subject { described_class.new(participant_profile:).record_state }

  describe "#status_name" do
    context "when the request for details has not been sent yet" do
      let(:participant_profile) { ect_on_fip_no_validation }
      it { is_expected.to eq "contacted_for_information" }
    end

    context "with a request for details email record" do
      context "which has been successfully delivered" do
        let(:participant_profile) { ect_on_fip_details_request_delivered }
        it { is_expected.to eq "contacted_for_information" }
      end

      context "which has failed to be deliver" do
        let(:participant_profile) { ect_on_fip_details_request_failed }
        it { is_expected.to eq "contacted_for_information" }
      end

      context "which is still pending" do
        let(:participant_profile) { ect_on_fip_details_request_submitted }
        it { is_expected.to eq "contacted_for_information" }
      end
    end

    context "mentor with multiple profiles" do
      context "when the primary profile is eligible" do
        let(:participant_profile) { mentor_profile_duplicity_primary }
        it { is_expected.to eq "training_or_eligible_for_training" }
      end

      context "when the secondary profile is ineligible because it is a duplicate" do
        let(:participant_profile) { mentor_profile_duplicity_secondary }
        it { is_expected.to eq "training_or_eligible_for_training" }
      end
    end

    context "full induction programme participant" do
      context "has submitted validation data" do
        let(:participant_profile) { ect_on_fip }
        it { is_expected.to eq "training_or_eligible_for_training" }
      end

      context "was a participant in early roll out" do
        let(:participant_profile) { mentor_ineligible_previous_participation }
        it { is_expected.to eq "training_or_eligible_for_training" }
      end

      context "has a withdrawn status" do
        context "when there is no induction record to use" do
          let(:participant_profile) { ect_on_fip_withdrawn_no_induction_record }
          it { is_expected.to eq "no_longer_being_trained" }
        end

        context "when an active induction record is available" do
          let(:participant_profile) { ect_on_fip_enrolled_after_withdraw }
          it { is_expected.to eq "training_or_eligible_for_training" }
        end
      end
    end

    context "core induction programme participant" do
      context "has submitted validation data" do
        let(:participant_profile) { ect_on_fip_no_tra_record }
        it { is_expected.to eq "dfe_checking_eligibility" }
      end

      context "has a previous induction reason" do
        let(:participant_profile) { ect_on_cip_ineligible_previous_induction }
        it { is_expected.to eq "not_eligible_for_funded_training" }
      end

      context "has no QTS reason" do
        let(:participant_profile) { ect_on_cip_manual_check_no_qts }
        it { is_expected.to eq "checking_qts" }
      end

      context "has an ineligible status" do
        let(:participant_profile) { ect_on_cip_ineligible_previous_participation }
        it { is_expected.to eq "not_eligible_for_funded_training" }
      end
    end
  end
end
