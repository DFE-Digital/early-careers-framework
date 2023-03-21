# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState, :with_training_record_state_examples do
  describe "#call" do
    context "when not called with a ParticipantProfile" do
      subject { described_class.call(participant_profile: TeacherProfile.new).record_state }

      it "Raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when not called with an InductionRecord" do
      subject { described_class.call(participant_profile: ect_on_cip_being_trained, induction_record: TeacherProfile.new).record_state }

      it "Raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when the training record is for an ECT doing ECF core induction training" do
      context "who is currently training" do
        subject { described_class.call(participant_profile: ect_on_cip_being_trained).record_state }
        it { is_expected.to eql :is_training }
      end

      context "who has been withdrawn by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_training).record_state }
        it { is_expected.to eql :has_withdrawn_from_training }
      end

      context "who has been deferred by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_cip_having_deferred_their_training).record_state }
        it { is_expected.to eql :has_deferred_their_training }
      end

      context "who has been withdrawn by their last school" do
        subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_programme).record_state }
        it { is_expected.to eql :has_withdrawn_from_programme }
      end
    end

    context "when the training record is for an ECT doing ECF full induction training" do
      context "and a request for details email has been submitted" do
        subject { described_class.call(participant_profile: ect_on_fip_with_details_request_submitted).record_state }
        it { is_expected.to eql :request_for_details_submitted }
      end

      context "and a request for details email has failed" do
        subject { described_class.call(participant_profile: ect_on_fip_with_details_request_failed).record_state }
        it { is_expected.to eql :request_for_details_failed }
      end

      context "and a request for details email has been delivered" do
        subject { described_class.call(participant_profile: ect_on_fip_with_details_request_delivered).record_state }
        it { is_expected.to eql :request_for_details_delivered }
      end

      context "who is eligible for funding" do
        subject { described_class.call(participant_profile: ect_on_fip_who_is_eligible_for_funding).record_state }
        it { is_expected.to eql :is_training }
      end

      context "who needs their active flags checking" do
        subject { described_class.call(participant_profile: ect_on_fip_who_needs_active_flags_checking).record_state }
        it { is_expected.to eql :needs_active_flags_checking }
      end

      context "who potentially has a different TRN on the TRA Record" do
        subject { described_class.call(participant_profile: ect_on_fip_who_needs_different_trn_checking).record_state }
        it { is_expected.to eql :needs_different_trn_checking }
      end

      context "who has no induction data yet" do
        subject { described_class.call(participant_profile: ect_on_fip_who_needs_induction_data_from_ab).record_state }
        it { is_expected.to eql :waiting_for_induction_data_from_ab }
      end

      context "who does not have QTS yet" do
        subject { described_class.call(participant_profile: ect_on_fip_who_is_waiting_for_qts).record_state }
        it { is_expected.to eql :waiting_for_qts }
      end

      context "who is ineligible because the active flags have been confirmed" do
        subject { described_class.call(participant_profile: ect_on_fip_who_has_active_flags).record_state }
        it { is_expected.to eql :ineligible_has_active_flags }
      end

      context "who is ineligible because they have a duplicate profile" do
        subject { described_class.call(participant_profile: ect_on_fip_who_has_duplicate_profile).record_state }
        it { is_expected.to eql :ineligible_has_duplicate_profile }
      end

      context "who is ineligible because they are exempt from induction" do
        subject { described_class.call(participant_profile: ect_on_fip_who_is_exempt_from_induction).record_state }
        it { is_expected.to eql :ineligible_is_exempt_from_induction }
      end

      context "who is ineligible because they have a previous induction" do
        subject { described_class.call(participant_profile: ect_on_fip_who_has_previous_induction).record_state }
        it { is_expected.to eql :ineligible_has_previous_induction }
      end

      context "who is ineligible because they have a previous participation" do
        subject { described_class.call(participant_profile: ect_on_fip_who_has_previous_participation).record_state }
        it { is_expected.to eql :ineligible_has_previous_participation }
      end

      context "who is currently training" do
        subject { described_class.call(participant_profile: ect_on_fip_being_trained).record_state }
        it { is_expected.to eql :is_training }
      end

      context "who has been withdrawn by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_training).record_state }
        it { is_expected.to eql :has_withdrawn_from_training }
      end

      context "who has been deferred by their last lead provider" do
        subject { described_class.call(participant_profile: ect_on_fip_having_deferred_their_training).record_state }
        it { is_expected.to eql :has_deferred_their_training }
      end

      context "who has been withdrawn by their last school" do
        subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_programme).record_state }
        it { is_expected.to eql :has_withdrawn_from_programme }
      end
    end
  end
end
