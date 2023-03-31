# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState, :with_training_record_state_examples do
  subject(:determined_state) { described_class.call(participant_profile:) }

  let(:admin_status) { StatusTags::AdminParticipantStatusTag.new(participant_profile:).label }
  let(:ab_status) { StatusTags::AppropriateBodyParticipantStatusTag.new(participant_profile:).label }
  let(:dp_status) { StatusTags::DeliveryPartnerParticipantStatusTag.new(participant_profile:).label }
  let(:school_status) { StatusTags::SchoolParticipantStatusTag.new(participant_profile:).label }

  shared_examples "determines states as" do |validation_state, training_eligibility_state, fip_funding_eligibility_state, training_state, record_state,
      admin_status_label:, ab_status_label: nil, dp_status_label: nil, school_status_label: nil|
    it "#validation_state is set to \":#{validation_state}\"" do
      expect(determined_state.validation_state).to eq validation_state
    end

    it "#training_eligibility_state is set to \":#{training_eligibility_state}\"" do
      expect(determined_state.training_eligibility_state).to eq training_eligibility_state
    end

    it "#fip_funding_eligibility_state is set to \":#{fip_funding_eligibility_state}\"" do
      expect(determined_state.fip_funding_eligibility_state).to eq fip_funding_eligibility_state
    end

    it "#training_state is set to \":#{training_state}\"" do
      expect(determined_state.training_state).to eq training_state
    end

    it "#record_state is set to \":#{record_state}\"" do
      expect(determined_state.record_state).to eq record_state
    end

    it "StatusTags::AdminParticipantStatusTag has the label \"#{admin_status_label}\"" do
      expect(admin_status).to eq admin_status_label
    end

    it "StatusTags::AppropriateBodyParticipantStatusTag has the label \"#{ab_status_label}\"" do
      expect(ab_status).to eq ab_status_label
    end

    it "StatusTags::DeliveryPartnerParticipantStatusTag has the label \"#{dp_status_label}\"" do
      expect(dp_status).to eq dp_status_label
    end

    it "StatusTags::SchoolParticipantStatusTag has the label \"#{school_status_label}\"" do
      expect(school_status).to eq school_status_label
    end
  end

  describe "#call" do
    context "when not called with a ParticipantProfile" do
      subject { described_class.call(participant_profile: TeacherProfile.new).record_state }

      it "Raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when not called with an InductionRecord" do
      subject { described_class.call(participant_profile: ect_on_cip, induction_record: TeacherProfile.new).record_state }

      it "Raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when a FIP ECT" do
      context "and is awaiting validation" do
        let(:participant_profile) { ect_on_fip_no_validation }

        include_examples "determines states as",
                         :validation_not_started,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :validation_not_started,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has been submitted" do
        let(:participant_profile) { ect_on_fip_details_request_submitted }

        include_examples "determines states as",
                         :request_for_details_submitted,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :request_for_details_submitted,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has failed" do
        let(:participant_profile) { ect_on_fip_details_request_failed }

        include_examples "determines states as",
                         :request_for_details_failed,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :request_for_details_failed,
                         admin_status_label: "Check email address",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Check email address"
      end

      context "and a request for details has been delivered" do
        let(:participant_profile) { ect_on_fip_details_request_delivered }

        include_examples "determines states as",
                         :request_for_details_delivered,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :request_for_details_delivered,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacted for information"
      end

      context "and the validation API has failed" do
        let(:participant_profile) { ect_on_fip_validation_api_failure }

        include_examples "determines states as",
                         :internal_error,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :internal_error,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and no TRA record could be found" do
        let(:participant_profile) { ect_on_fip_no_tra_record }

        include_examples "determines states as",
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_fip_training,
                         :tra_record_not_found,
                         admin_status_label: "DfE checking eligibility", # TODO: conflict with ect_on_fip_no_validation !!
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the school is eligible for sparsity uplift" do
        let(:participant_profile) { ect_on_fip_sparsity_uplift }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the school is eligible for pupil premium uplift" do
        let(:participant_profile) { ect_on_fip_pupil_premium_uplift }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the school has no eligible uplifts" do
        let(:participant_profile) { ect_on_fip_no_uplift }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and active flags have been found on the TRA record" do
        let(:participant_profile) { ect_on_fip_manual_check_active_flags }

        include_examples "determines states as",
                         :valid,
                         :active_flags,
                         :active_flags,
                         :active_fip_training,
                         :active_flags,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and a different TRN was identified with the details provided" do
        let(:participant_profile) { ect_on_fip_manual_check_different_trn }

        include_examples "determines states as",
                         :different_trn,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :different_trn,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let(:participant_profile) { ect_on_fip_manual_check_no_induction }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :no_induction_start,
                         :no_induction_start,
                         :no_induction_start,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they do not have QTS on record" do
        let(:participant_profile) { ect_on_fip_manual_check_no_qts }

        include_examples "determines states as",
                         :valid,
                         :not_qualified,
                         :not_qualified,
                         :active_fip_training,
                         :not_qualified,
                         admin_status_label: "Not eligible: No QTS",
                         ab_status_label: "Checking QTS",
                         dp_status_label: "Checking QTS",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let(:participant_profile) { ect_on_fip_ineligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :not_allowed,
                         :not_allowed,
                         :active_fip_training,
                         :not_allowed,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let(:participant_profile) { ect_on_fip_eligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let(:participant_profile) { ect_on_fip_ineligible_duplicate_profile }

        include_examples "determines states as",
                         :valid,
                         :duplicate_profile,
                         :duplicate_profile,
                         :active_fip_training,
                         :duplicate_profile,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they are exempt from induction" do
        let(:participant_profile) { ect_on_fip_ineligible_exempt_from_induction }

        include_examples "determines states as",
                         :valid,
                         :exempt_from_induction,
                         :exempt_from_induction,
                         :active_fip_training,
                         :exempt_from_induction,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a previous induction recorded" do
        let(:participant_profile) { ect_on_fip_ineligible_previous_induction }

        include_examples "determines states as",
                         :valid,
                         :previous_induction,
                         :previous_induction,
                         :active_fip_training,
                         :previous_induction,
                         admin_status_label: "Not eligible: NQT+1",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a previous participation recorded" do
        let(:participant_profile) { ect_on_fip_ineligible_previous_participation }

        include_examples "determines states as",
                         :valid,
                         :previous_participation,
                         :previous_participation,
                         :active_fip_training,
                         :previous_participation,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have had no eligibility checks performed yet" do
        let(:participant_profile) { ect_on_fip_no_eligibility_checks }

        include_examples "determines states as",
                         :valid,
                         :checks_not_complete,
                         :checks_not_complete,
                         :active_fip_training,
                         :checks_not_complete,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been made eligible by DfE" do
        let(:participant_profile) { ect_on_fip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the school has not yet reported the training providers" do
        let(:participant_profile) { ect_on_fip_no_partnership }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they are active" do
        let(:participant_profile) { ect_on_fip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let(:participant_profile) { ect_on_fip_withdrawn }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let(:participant_profile) { ect_on_fip_enrolled_after_withdraw }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_fip_training,
                         :active_fip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let(:participant_profile) { ect_on_fip_withdrawn_no_induction_record }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "DfE checking eligibility"
      end

      context "and their training has been deferred" do
        let(:participant_profile) { ect_on_fip_deferred }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :deferred_training,
                         :deferred_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been withdrawn from the programme" do
        let(:participant_profile) { ect_on_fip_withdrawn_from_programme }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_programme,
                         :withdrawn_programme,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      # TODO: need to include all four transfer scenarios
      context "and they are leaving their current school" do
        let(:participant_profile) { ect_on_fip_leaving }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :leaving,
                         :leaving,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have completed their induction training" do
        let(:participant_profile) { ect_on_fip_completed }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :completed_training,
                         :completed_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end
    end

    context "when a CIP ECT" do
      context "and is awaiting validation" do
        let(:participant_profile) { ect_on_cip_no_validation }

        include_examples "determines states as",
                         :validation_not_started,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :validation_not_started,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has been submitted" do
        let(:participant_profile) { ect_on_cip_details_request_submitted }

        include_examples "determines states as",
                         :request_for_details_submitted,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :request_for_details_submitted,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has failed" do
        let(:participant_profile) { ect_on_cip_details_request_failed }

        include_examples "determines states as",
                         :request_for_details_failed,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :request_for_details_failed,
                         admin_status_label: "Check email address",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Check email address"
      end

      context "and a request for details has been delivered" do
        let(:participant_profile) { ect_on_cip_details_request_delivered }

        include_examples "determines states as",
                         :request_for_details_delivered,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :request_for_details_delivered,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacted for information"
      end

      context "and the validation API has failed" do
        let(:participant_profile) { ect_on_cip_validation_api_failure }

        include_examples "determines states as",
                         :internal_error,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :internal_error,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and no TRA record could be found" do
        let(:participant_profile) { ect_on_cip_no_tra_record }

        include_examples "determines states as",
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :tra_record_not_found,
                         :active_cip_training,
                         :tra_record_not_found,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and active flags have been found on the TRA record" do
        let(:participant_profile) { ect_on_cip_manual_check_active_flags }

        include_examples "determines states as",
                         :valid,
                         :active_flags,
                         :active_flags,
                         :active_cip_training,
                         :active_flags,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and a different TRN was identified with the details provided" do
        let(:participant_profile) { ect_on_cip_manual_check_different_trn }

        include_examples "determines states as",
                         :different_trn,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_cip_training,
                         :different_trn,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let(:participant_profile) { ect_on_cip_manual_check_no_induction }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :no_induction_start,
                         :no_induction_start,
                         :no_induction_start,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and they do not have QTS on record" do
        let(:participant_profile) { ect_on_cip_manual_check_no_qts }

        include_examples "determines states as",
                         :valid,
                         :not_qualified,
                         :not_qualified,
                         :active_cip_training,
                         :not_qualified,
                         admin_status_label: "Not eligible: No QTS",
                         ab_status_label: "Checking QTS",
                         dp_status_label: "Checking QTS",
                         school_status_label: "Eligible to start"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let(:participant_profile) { ect_on_cip_ineligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :not_allowed,
                         :not_allowed,
                         :active_cip_training,
                         :not_allowed,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let(:participant_profile) { ect_on_cip_eligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_cip_training,
                         :active_cip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let(:participant_profile) { ect_on_cip_ineligible_duplicate_profile }

        include_examples "determines states as",
                         :valid,
                         :duplicate_profile,
                         :duplicate_profile,
                         :active_cip_training,
                         :duplicate_profile,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and they are exempt from induction" do
        let(:participant_profile) { ect_on_cip_ineligible_exempt_from_induction }

        include_examples "determines states as",
                         :valid,
                         :exempt_from_induction,
                         :exempt_from_induction,
                         :active_cip_training,
                         :exempt_from_induction,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a previous induction recorded" do
        let(:participant_profile) { ect_on_cip_ineligible_previous_induction }

        include_examples "determines states as",
                         :valid,
                         :previous_induction,
                         :previous_induction,
                         :active_cip_training,
                         :previous_induction,
                         admin_status_label: "Not eligible: NQT+1",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a previous participation recorded" do
        let(:participant_profile) { ect_on_cip_ineligible_previous_participation }

        include_examples "determines states as",
                         :valid,
                         :previous_participation,
                         :previous_participation,
                         :active_cip_training,
                         :previous_participation,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and they have had no eligibility checks performed yet" do
        let(:participant_profile) { ect_on_cip_no_eligibility_checks }

        include_examples "determines states as",
                         :valid,
                         :checks_not_complete,
                         :checks_not_complete,
                         :active_cip_training,
                         :checks_not_complete,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and they have been made eligible by DfE" do
        let(:participant_profile) { ect_on_cip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_cip_training,
                         :active_cip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they are active" do
        let(:participant_profile) { ect_on_cip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_cip_training,
                         :active_cip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let(:participant_profile) { ect_on_cip_withdrawn }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "Eligible to start"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let(:participant_profile) { ect_on_cip_enrolled_after_withdraw }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :active_cip_training,
                         :active_cip_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let(:participant_profile) { ect_on_cip_withdrawn_no_induction_record }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "DfE checking eligibility"
      end

      context "and their training has been deferred" do
        let(:participant_profile) { ect_on_cip_deferred }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :deferred_training,
                         :deferred_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have been withdrawn from the programme" do
        let(:participant_profile) { ect_on_cip_withdrawn_from_programme }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :withdrawn_programme,
                         :withdrawn_programme,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      # TODO: need to include all four transfer scenarios
      context "and they are leaving their current school" do
        let(:participant_profile) { ect_on_cip_leaving }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :leaving,
                         :leaving,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have completed their induction training" do
        let(:participant_profile) { ect_on_cip_completed }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_induction_training,
                         :eligible_for_fip_funding,
                         :completed_training,
                         :completed_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end
    end

    context "when a FIP Mentor" do
      context "and is awaiting validation" do
        let(:participant_profile) { mentor_on_fip_no_validation }

        include_examples "determines states as",
                         :validation_not_started,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :validation_not_started,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has been submitted" do
        let(:participant_profile) { mentor_on_fip_details_request_submitted }

        include_examples "determines states as",
                         :request_for_details_submitted,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_submitted,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has failed" do
        let(:participant_profile) { mentor_on_fip_details_request_failed }

        include_examples "determines states as",
                         :request_for_details_failed,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_failed,
                         admin_status_label: "Check email address",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Check email address"
      end

      context "and a request for details has been delivered" do
        let(:participant_profile) { mentor_on_fip_details_request_delivered }

        include_examples "determines states as",
                         :request_for_details_delivered,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_delivered,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacted for information"
      end

      context "and the validation API has failed" do
        let(:participant_profile) { mentor_on_fip_validation_api_failure }

        include_examples "determines states as",
                         :internal_error,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :internal_error,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and no TRA record could be found" do
        let(:participant_profile) { mentor_on_fip_no_tra_record }

        include_examples "determines states as",
                         :tra_record_not_found,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :tra_record_not_found,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and active flags have been found on the TRA record" do
        let(:participant_profile) { mentor_on_fip_manual_check_active_flags }

        include_examples "determines states as",
                         :valid,
                         :active_flags,
                         :active_flags,
                         :registered_for_mentor_training,
                         :active_flags,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and a different TRN was identified with the details provided" do
        let(:participant_profile) { mentor_on_fip_manual_check_different_trn }

        include_examples "determines states as",
                         :different_trn,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :different_trn,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they do not have QTS on record" do
        let(:participant_profile) { mentor_on_fip_manual_check_no_qts }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Checking QTS",
                         dp_status_label: "Checking QTS",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let(:participant_profile) { mentor_on_fip_eligible_no_qts }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let(:participant_profile) { mentor_on_fip_ineligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :not_allowed,
                         :not_allowed,
                         :registered_for_mentor_training,
                         :not_allowed,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let(:participant_profile) { mentor_on_fip_eligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let(:participant_profile) { mentor_on_fip_ineligible_duplicate_profile }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_duplicate,
                         :registered_for_mentor_training_duplicate,
                         admin_status_label: "Eligible: Mentor at additional school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a previous participation recorded" do
        let(:participant_profile) { mentor_ero_on_fip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training_ero,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_ero,
                         :registered_for_mentor_training_ero,
                         admin_status_label: "Eligible to start: ERO",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let(:participant_profile) { mentor_ero_on_fip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have had no eligibility checks performed yet" do
        let(:participant_profile) { mentor_on_fip_no_eligibility_checks }

        include_examples "determines states as",
                         :valid,
                         :checks_not_complete,
                         :checks_not_complete,
                         :registered_for_mentor_training,
                         :checks_not_complete,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been made eligible by DfE" do
        let(:participant_profile) { mentor_on_fip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let(:participant_profile) { mentor_on_fip_profile_duplicity_primary }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_primary,
                         :registered_for_mentor_training_primary, # TODO: primary_mentor_profile
                         admin_status_label: "Eligible: Mentor at main school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let(:participant_profile) { mentor_on_fip_profile_duplicity_secondary }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_secondary,
                         :registered_for_mentor_training_secondary,
                         admin_status_label: "Eligible: Mentor at additional school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and the school has not yet reported the training providers" do
        let(:participant_profile) { mentor_on_fip_no_partnership }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they are active" do
        let(:participant_profile) { mentor_on_fip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let(:participant_profile) { mentor_on_fip_withdrawn }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let(:participant_profile) { mentor_on_fip_enrolled_after_withdraw }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let(:participant_profile) { mentor_on_fip_withdrawn_no_induction_record }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "DfE checking eligibility"
      end

      context "and their training has been deferred" do
        let(:participant_profile) { mentor_on_fip_deferred }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :deferred_training,
                         :deferred_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been withdrawn from the programme" do
        let(:participant_profile) { mentor_on_fip_withdrawn_from_programme }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_programme,
                         :withdrawn_programme,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      # TODO: need to include all four transfer scenarios
      context "and they are leaving their current school" do
        let(:participant_profile) { mentor_on_fip_leaving }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :leaving,
                         :leaving,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have completed their induction training" do
        let(:participant_profile) { mentor_on_fip_completed }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :completed_training,
                         :completed_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end
    end

    context "when a CIP Mentor" do
      context "and is awaiting validation" do
        let(:participant_profile) { mentor_on_cip_no_validation }

        include_examples "determines states as",
                         :validation_not_started,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :validation_not_started,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has been submitted" do
        let(:participant_profile) { mentor_on_cip_details_request_submitted }

        include_examples "determines states as",
                         :request_for_details_submitted,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_submitted,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacting for information"
      end

      context "and a request for details has failed" do
        let(:participant_profile) { mentor_on_cip_details_request_failed }

        include_examples "determines states as",
                         :request_for_details_failed,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_failed,
                         admin_status_label: "Check email address",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Check email address"
      end

      context "and a request for details has been delivered" do
        let(:participant_profile) { mentor_on_cip_details_request_delivered }

        include_examples "determines states as",
                         :request_for_details_delivered,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :request_for_details_delivered,
                         admin_status_label: "Contacted for information",
                         ab_status_label: "Contacted for information",
                         dp_status_label: "Contacted for information",
                         school_status_label: "Contacted for information"
      end

      context "and the validation API has failed" do
        let(:participant_profile) { mentor_on_cip_validation_api_failure }

        include_examples "determines states as",
                         :internal_error,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :internal_error,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and no TRA record could be found" do
        let(:participant_profile) { mentor_on_cip_no_tra_record }

        include_examples "determines states as",
                         :tra_record_not_found,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :tra_record_not_found,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and active flags have been found on the TRA record" do
        let(:participant_profile) { mentor_on_cip_manual_check_active_flags }

        include_examples "determines states as",
                         :valid,
                         :active_flags,
                         :active_flags,
                         :registered_for_mentor_training,
                         :active_flags,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and a different TRN was identified with the details provided" do
        let(:participant_profile) { mentor_on_cip_manual_check_different_trn }

        include_examples "determines states as",
                         :different_trn,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :different_trn,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and they do not have QTS on record" do
        let(:participant_profile) { mentor_on_cip_manual_check_no_qts }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Checking QTS",
                         dp_status_label: "Checking QTS",
                         school_status_label: "Eligible to start"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let(:participant_profile) { mentor_on_cip_eligible_no_qts }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let(:participant_profile) { mentor_on_cip_ineligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :not_allowed,
                         :not_allowed,
                         :registered_for_mentor_training,
                         :not_allowed,
                         admin_status_label: "Not eligible",
                         ab_status_label: "Not eligible for funded training",
                         dp_status_label: "Not eligible for funded training",
                         school_status_label: "Eligible to start"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let(:participant_profile) { mentor_on_cip_eligible_active_flags }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let(:participant_profile) { mentor_on_cip_ineligible_duplicate_profile }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_duplicate,
                         :registered_for_mentor_training_duplicate,
                         admin_status_label: "Eligible: Mentor at additional school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a previous participation recorded" do
        let(:participant_profile) { mentor_ero_on_cip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training_ero,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_ero,
                         :registered_for_mentor_training_ero,
                         admin_status_label: "Eligible to start: ERO",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let(:participant_profile) { mentor_ero_on_cip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have had no eligibility checks performed yet" do
        let(:participant_profile) { mentor_on_cip_no_eligibility_checks }

        include_examples "determines states as",
                         :valid,
                         :checks_not_complete,
                         :checks_not_complete,
                         :registered_for_mentor_training,
                         :checks_not_complete,
                         admin_status_label: "DfE checking eligibility",
                         ab_status_label: "DfE checking eligibility",
                         dp_status_label: "DfE checking eligibility",
                         school_status_label: "Eligible to start"
      end

      context "and they have been made eligible by DfE" do
        let(:participant_profile) { mentor_on_cip_eligible }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let(:participant_profile) { mentor_on_cip_profile_duplicity_primary }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_primary,
                         :registered_for_mentor_training_primary,
                         admin_status_label: "Eligible: Mentor at main school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let(:participant_profile) { mentor_on_cip_profile_duplicity_secondary }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training_secondary,
                         :registered_for_mentor_training_secondary,
                         admin_status_label: "Eligible: Mentor at additional school",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they are active" do
        let(:participant_profile) { mentor_on_cip }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let(:participant_profile) { mentor_on_cip_withdrawn }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "Eligible to start"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let(:participant_profile) { mentor_on_cip_enrolled_after_withdraw }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :registered_for_mentor_training,
                         :registered_for_mentor_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let(:participant_profile) { mentor_on_cip_withdrawn_no_induction_record }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_training,
                         :withdrawn_training,
                         admin_status_label: "Withdrawn by provider",
                         ab_status_label: "No longer being trained",
                         dp_status_label: "No longer being trained",
                         school_status_label: "Eligible to start"
      end

      context "and their training has been deferred" do
        let(:participant_profile) { mentor_on_cip_deferred }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :deferred_training,
                         :deferred_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "DfE checking eligibility"
      end

      context "and they have been withdrawn from the programme" do
        let(:participant_profile) { mentor_on_cip_withdrawn_from_programme }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :withdrawn_programme,
                         :withdrawn_programme,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      # TODO: need to include all four transfer scenarios
      context "and they are leaving their current school" do
        let(:participant_profile) { mentor_on_cip_leaving }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :leaving,
                         :leaving,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end

      context "and they have completed their induction training" do
        let(:participant_profile) { mentor_on_cip_completed }

        include_examples "determines states as",
                         :valid,
                         :eligible_for_mentor_training,
                         :eligible_for_mentor_funding,
                         :completed_training,
                         :completed_training,
                         admin_status_label: "Eligible to start",
                         ab_status_label: "Training or eligible for training",
                         dp_status_label: "Training or eligible for training",
                         school_status_label: "Eligible to start"
      end
    end
  end
end
