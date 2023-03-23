# frozen_string_literal: true

RSpec.describe SchoolParticipantStatusTagStatus, with_feature_flags: { eligibility_notifications: "active" } do
  subject { described_class.new(participant_profile:).record_state }

  context "when an email has been sent but the participant has not validated" do
    let(:participant_profile) { create(:ect_participant_profile, :email_sent) }

    it { is_expected.to eq :details_required } # "details_required"
  end

  context "when an email bounced" do
    let(:participant_profile) { create(:ect_participant_profile, :email_bounced) }

    it { is_expected.to eq :request_for_details_failed } #  "request_for_details_failed"
  end

  context "when no email has been sent" do
    let(:participant_profile) { create(:ect_participant_profile) }

    it { is_expected.to eq :request_to_be_sent } #  request_to_be_sent
  end

  context "when the participant is doing FIP" do
    let(:school_cohort) { create(:school_cohort, :fip) }

    context "when the participant is an ECT" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it { is_expected.to eq :eligible_fip_no_partner } #  eligible_fip_no_partner
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it { is_expected.to eq :fip_ect_no_qts } # fip_ect_no_qts
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

        it { is_expected.to eq :ineligible_previous_induction } # ineligible_previous_induction
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it { is_expected.to eq :eligible_fip_no_partner } #  eligible_fip_no_partner
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

        it { is_expected.to eq :ero_mentor } #  ero_mentor - TODO: does this check mentor participation
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end

      context "when the participant is a duplicate profile" do
        let(:participant_profile) { create(:mentor_participant_profile, :secondary_profile, school_cohort:) }
        let!(:eligibility) { create(:ecf_participant_eligibility, :secondary_profile_state, participant_profile:) }

        before { participant_profile.reload }

        it { is_expected.to eq :eligible_fip_no_partner } #  eligible_fip_no_partner
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it { is_expected.to eq :checking_eligibility } #  checking_eligibility
      end
    end
  end

  context "when the participant is doing CIP" do
    let(:school_cohort) { create(:school_cohort, :cip) }

    context "when the participant is an ECT" do
      let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has a previous induction" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_induction_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end
    end

    context "when the participant is a mentor" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
      let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile:) }

      context "when the participant is eligible" do
        let!(:eligibility) { create(:ecf_participant_eligibility, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has no QTS" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :no_qts_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has a previous participation (ERO)" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :previous_participation_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has a TRN mismatch" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :different_trn_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end

      context "when the participant has active flags and manual check status" do
        let!(:eligibility) { create(:ecf_participant_eligibility, :active_flags_state, participant_profile:) }

        it { is_expected.to eq :eligible_cip } #  eligible_cip
      end
    end
  end
end
