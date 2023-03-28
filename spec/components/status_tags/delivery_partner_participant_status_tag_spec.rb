# frozen_string_literal: true

RSpec.describe StatusTags::DeliveryPartnerParticipantStatusTag, :with_training_record_state_examples, type: :component do
  let(:induction_record) { participant_profile.induction_records.latest }

  subject { render_inline described_class.new(participant_profile:, induction_record:) }

  context "when the request for details has not been sent yet" do
    let(:participant_profile) { ect_on_fip_no_validation }
    it { is_expected.to have_text "Contacted for information" }
  end

  context "with a request for details email record" do
    context "which has been successfully delivered" do
      let(:participant_profile) { ect_on_fip_details_request_delivered }
      it { is_expected.to have_text "Contacted for information" }
    end

    context "which has failed to be deliver" do
      let(:participant_profile) { ect_on_fip_details_request_failed }
      it { is_expected.to have_text "Contacted for information" }
    end

    context "which is still pending" do
      let(:participant_profile) { ect_on_fip_details_request_submitted }
      it { is_expected.to have_text "Contacted for information" }
    end
  end

  context "mentor with multiple profiles" do
    context "when the primary profile is eligible" do
      let(:participant_profile) { mentor_profile_duplicity_primary }
      it { is_expected.to have_text "Training or eligible for training" }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { mentor_profile_duplicity_secondary }
      it { is_expected.to have_text "Training or eligible for training" }
    end

    context "when participant is Mentor and Induction Tutor", skip: "relating to DP table row only" do
      let(:participant_profile) { mentor }
      let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, user: participant_profile.user) }

      it { is_expected.to have_text "Mentor" }
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip }
      it { is_expected.to have_text "Training or eligible for training" }
    end

    context "was a participant in early roll out" do
      let(:participant_profile) { mentor_ineligible_previous_participation }
      it { is_expected.to have_text "Training or eligible for training" }
    end

    context "has a withdrawn status" do
      context "when there is no induction record to use" do
        let(:participant_profile) { ect_on_fip_withdrawn_no_induction_record }
        it { is_expected.to have_text "No longer being trained" }
      end

      context "when an active induction record is available" do
        let(:participant_profile) { ect_on_fip_enrolled_after_withdraw }
        it { is_expected.to have_text "Training or eligible for training" }
      end
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip_no_tra_record }
      it { is_expected.to have_text "DfE checking eligibility" }
    end

    context "has a previous induction reason" do
      let(:participant_profile) { ect_on_cip_ineligible_previous_induction }
      it { is_expected.to have_text "Not eligible for funded training" }
    end

    context "has no QTS reason" do
      let(:participant_profile) { ect_on_cip_manual_check_no_qts }
      it { is_expected.to have_text "Checking QTS" }
    end

    context "has an ineligible status" do
      let(:participant_profile) { ect_on_cip_ineligible_previous_participation }
      it { is_expected.to have_text "Not eligible" }
    end
  end
end
