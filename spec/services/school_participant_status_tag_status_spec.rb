# frozen_string_literal: true

RSpec.describe SchoolParticipantStatusTagStatus, :with_training_record_state_examples, with_feature_flags: { eligibility_notifications: "active" } do
  subject { described_class.new(participant_profile:).record_state }

  context "when a participant has not validated" do
    context "and the request for details email needs to be sent out" do
      let(:participant_profile) { ect_on_fip_no_validation }
      it { is_expected.to eq :request_to_be_sent }
    end

    context "and the request for details email has been submitted to GOV UK Notify" do
      let(:participant_profile) { ect_on_fip_details_request_submitted }
      it { is_expected.to eq :request_to_be_sent }
    end

    context "and the request for details email has been sent out" do
      let(:participant_profile) { ect_on_fip_details_request_delivered }
      it { is_expected.to eq :details_required }
    end

    context "and the request for details email has bounced" do
      let(:participant_profile) { ect_on_fip_details_request_failed }
      it { is_expected.to eq :request_for_details_failed }
    end
  end

  context "when the participant is doing FIP" do
    context "and is an ECT" do
      context "and is eligible" do
        let(:participant_profile) { ect_on_fip_eligible }
        it { is_expected.to eq :eligible_fip } #  eligible_fip
      end

      context "and school has no partnership" do
        let(:participant_profile) { ect_on_fip_no_partnership }
        it { is_expected.to eq :eligible_fip_no_partner } #  eligible_fip_no_partner
      end

      context "and has no QTS" do
        let(:participant_profile) { ect_on_fip_manual_check_no_qts }
        it { is_expected.to eq :fip_ect_no_qts } # fip_ect_no_qts
      end

      context "and has a previous induction" do
        let(:participant_profile) { ect_on_fip_ineligible_previous_induction }
        it { is_expected.to eq :ineligible_previous_induction } # ineligible_previous_induction
      end

      context "and has a TRN mismatch" do
        let(:participant_profile) { ect_on_fip_manual_check_different_trn }
        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end

      context "and has active flags and manual check status" do
        let(:participant_profile) { ect_on_fip_manual_check_active_flags }
        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end
    end

    context "and is a mentor" do
      context "and is eligible" do
        let(:participant_profile) { mentor_on_fip_eligible }
        it { is_expected.to eq :eligible_fip } #  eligible_fip
      end

      context "and school has no partnership" do
        let(:participant_profile) { mentor_on_fip_no_partnership }
        it { is_expected.to eq :eligible_fip_no_partner } #  eligible_fip_no_partner
      end

      context "and has no QTS", skip: "logic not currently available" do
        let(:participant_profile) { mentor_on_fip_manual_check_no_qts }
        it { is_expected.to eq :eligible_fip } # eligible_fip
      end

      context "and has a previous participation (ERO)" do
        let(:participant_profile) { mentor_ero_on_fip }
        it { is_expected.to eq :ero_mentor } #  ero_mentor
      end

      context "and has a previous participation (ERO) and has been made eligible", skip: "needs to ignore status" do
        let(:participant_profile) { mentor_ero_on_fip_eligible }
        it { is_expected.to eq :ero_mentor } #  ero_mentor
      end

      context "and has a TRN mismatch" do
        let(:participant_profile) { mentor_on_fip_manual_check_different_trn }
        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end

      context "and is a duplicate profile" do
        let(:participant_profile) { mentor_on_fip_profile_duplicity_secondary }
        it { is_expected.to eq :eligible_fip } #  eligible_fip_no_partner
      end

      context "and has active flags and manual check status" do
        let(:participant_profile) { mentor_on_fip_manual_check_active_flags }
        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end
    end
  end

  context "when the participant is doing CIP" do
    context "and is an ECT" do
      context "and is eligible" do
        let(:participant_profile) { ect_on_cip_eligible }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "and has no QTS" do
        let(:participant_profile) { ect_on_cip_manual_check_no_qts }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "and has a previous induction" do
        let(:participant_profile) { ect_on_cip_ineligible_previous_induction }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "and has a TRN mismatch" do
        let(:participant_profile) { ect_on_cip_manual_check_different_trn }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "and has active flags and manual check status" do
        let(:participant_profile) { ect_on_cip_manual_check_active_flags }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end
    end

    context "when the participant is a mentor" do
      context "and is eligible" do
        let(:participant_profile) { mentor_on_cip }
        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "and has no QTS" do
        let(:participant_profile) { mentor_on_cip_manual_check_no_qts }
        it { is_expected.to eq :eligible_cip } # eligible_fip
      end

      context "and has a previous participation (ERO)" do
        let(:participant_profile) { mentor_ero_on_cip }
        it { is_expected.to eq :eligible_cip } #  ero_mentor
      end

      context "and has a previous participation (ERO) and has been made eligible" do
        let(:participant_profile) { mentor_ero_on_cip_eligible }
        it { is_expected.to eq :eligible_cip } #  ero_mentor
      end

      context "and has a TRN mismatch" do
        let(:participant_profile) { mentor_on_cip_manual_check_different_trn }
        it { is_expected.to eq :eligible_cip } #  checking_eligibility
      end

      context "and is a duplicate profile" do
        let(:participant_profile) { mentor_on_cip_profile_duplicity_secondary }
        it { is_expected.to eq :eligible_cip } #  eligible_fip_no_partner
      end

      context "and has active flags and manual check status" do
        let(:participant_profile) { mentor_on_cip_manual_check_active_flags }
        it { is_expected.to eq :eligible_cip } #  checking_eligibility
      end
    end
  end
end
