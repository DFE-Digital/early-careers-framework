# frozen_string_literal: true

RSpec.describe AdminParticipantStatusTagStatus, :with_training_record_state_examples do
  subject { described_class.new(participant_profile:).record_state }

  context "when the request for details has not been sent yet" do
    let(:participant_profile) { ect_on_fip_no_validation }
    it { is_expected.to eq :checks_not_complete } # "Contacting for information"
  end

  context "with a request for details email record" do
    context "which has been successfully delivered" do
      let(:participant_profile) { ect_on_fip_details_request_delivered }
      it { is_expected.to eq :request_for_details_delivered } # "Contacted for information"
    end

    context "which has failed to be deliver" do
      let(:participant_profile) { ect_on_fip_details_request_failed }
      it { is_expected.to eq :request_for_details_failed } # "Check email address"
    end

    context "which is still pending" do
      let(:participant_profile) { ect_on_fip_details_request_submitted }
      it { is_expected.to eq :checks_not_complete } # "Contacting for information"
    end
  end

  context "mentor with multiple profiles" do
    context "when the primary profile is eligible" do
      let(:participant_profile) { mentor_on_fip_profile_duplicity_primary }
      it { is_expected.to eq :registered_for_mentor_training } # "Eligible: Mentor at main school" }
    end

    context "when the secondary profile is ineligible because it is a duplicate" do
      let(:participant_profile) { mentor_on_fip_profile_duplicity_secondary }
      it { is_expected.to eq :registered_for_mentor_training_second_school } # "Eligible: Mentor at additional school"
    end
  end

  context "full induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip }
      it { is_expected.to eq :registered_for_fip_training } # "Eligible to start"
    end

    context "was a participant in early roll out" do
      let(:participant_profile) { mentor_ero_on_fip }
      it { is_expected.to eq :previous_participation_ero } # "Eligible to start: ERO"
    end

    context "has a withdrawn status" do
      context "when there is no induction record to use" do
        let(:participant_profile) { ect_on_fip_withdrawn_no_induction_record }
        it { is_expected.to eq :withdrawn_training } # "Withdrawn by provider"
      end

      context "when an active induction record is available" do
        let(:participant_profile) { ect_on_fip_enrolled_after_withdraw }
        it { is_expected.to eq :registered_for_fip_training } # "Eligible to start" }
      end
    end
  end

  context "core induction programme participant" do
    context "has submitted validation data" do
      let(:participant_profile) { ect_on_fip_no_tra_record }
      it { is_expected.to eq :manual_check } # "DfE checking eligibility"
    end

    context "has a previous induction reason" do
      # TODO: this will not always be NQT+1
      let(:participant_profile) { ect_on_cip_ineligible_previous_induction }
      it { is_expected.to eq :previous_induction } # "Not eligible: NQT+1"
    end

    context "has no QTS reason" do
      let(:participant_profile) { ect_on_cip_manual_check_no_qts }
      it { is_expected.to eq :not_qualified } # "Not eligible: No QTS"
    end

    context "has an ineligible status" do
      let(:participant_profile) { ect_on_cip_ineligible_previous_participation }
      it { is_expected.to eq :ineligible } # "Not eligible"
    end
  end
end
