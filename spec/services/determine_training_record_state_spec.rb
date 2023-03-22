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
      subject { described_class.call(participant_profile: ect_on_cip, induction_record: TeacherProfile.new).record_state }

      it "Raises an ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "validation checks" do
      context "for Full Induction Programme ECTs" do
        context "found different TRN in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_different_trn).validation_state }
          it { is_expected.to eql :different_trn }
        end

        context "request for details email has been submitted to GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_submitted).validation_state }
          it { is_expected.to eql :request_for_details_submitted }
        end

        context "request for details email has failed to be delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_failed).validation_state }
          it { is_expected.to eql :request_for_details_failed }
        end

        context "request for details email has been delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_delivered).validation_state }
          it { is_expected.to eql :request_for_details_delivered }
        end

        context "TRA Qualifications API failed" do
          subject { described_class.call(participant_profile: ect_on_fip_validation_api_failure).validation_state }
          it { is_expected.to eql :internal_error }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_fip_no_tra_record).validation_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "confirm valid record" do
          subject { described_class.call(participant_profile: ect_on_fip).validation_state }
          it { is_expected.to eql :valid }
        end
      end

      context "for Core Induction Programme ECTs" do
        context "found different TRN in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_different_trn).validation_state }
          it { is_expected.to eql :different_trn }
        end

        context "request for details email has been submitted to GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_cip_details_request_submitted).validation_state }
          it { is_expected.to eql :request_for_details_submitted }
        end

        context "request for details email has failed to be delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_cip_details_request_failed).validation_state }
          it { is_expected.to eql :request_for_details_failed }
        end

        context "request for details email has been delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: ect_on_cip_details_request_delivered).validation_state }
          it { is_expected.to eql :request_for_details_delivered }
        end

        context "TRA Qualifications API failed" do
          subject { described_class.call(participant_profile: ect_on_cip_validation_api_failure).validation_state }
          it { is_expected.to eql :internal_error }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_cip_no_tra_record).validation_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "confirm valid record" do
          subject { described_class.call(participant_profile: ect_on_cip).validation_state }
          it { is_expected.to eql :valid }
        end
      end

      context "for ECF Mentors" do
        context "found different TRN in TRA Records" do
          subject { described_class.call(participant_profile: mentor_manual_check_different_trn).validation_state }
          it { is_expected.to eql :different_trn }
        end

        context "request for details email has been submitted to GOV UK Notify service" do
          subject { described_class.call(participant_profile: mentor_details_request_submitted).validation_state }
          it { is_expected.to eql :request_for_details_submitted }
        end

        context "request for details email has failed to be delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: mentor_details_request_failed).validation_state }
          it { is_expected.to eql :request_for_details_failed }
        end

        context "request for details email has been delivered by GOV UK Notify service" do
          subject { described_class.call(participant_profile: mentor_details_request_delivered).validation_state }
          it { is_expected.to eql :request_for_details_delivered }
        end

        context "TRA Qualifications API failed" do
          subject { described_class.call(participant_profile: mentor_validation_api_failure).validation_state }
          it { is_expected.to eql :internal_error }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: mentor_no_tra_record).validation_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "confirm valid record" do
          subject { described_class.call(participant_profile: mentor).validation_state }
          it { is_expected.to eql :valid }
        end
      end
    end

    context "training eligibility" do
      context "for Full Induction Programme ECTs" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_duplicate_profile).training_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_active_flags).training_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_active_flags).training_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "with no QTS recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_no_qts).training_eligibility_state }
          it { is_expected.to eql :not_qualified }
        end

        context "found to be exempt from the requirement for a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_exempt_from_induction).training_eligibility_state }
          it { is_expected.to eql :exempt_from_induction }
        end

        context "found to have completed a previous statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_induction).training_eligibility_state }
          it { is_expected.to eql :previous_induction }
        end

        context "found to have already participated in a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_participation).training_eligibility_state }
          it { is_expected.to eql :previous_participation }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_fip_no_tra_record).training_eligibility_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_fip_no_eligibility_checks).training_eligibility_state }
          it { is_expected.to eql :checks_not_complete }
        end

        context "made to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_fip_eligible).training_eligibility_state }
          it { is_expected.to eql :induction_training_required }
        end

        context "found to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_fip).training_eligibility_state }
          it { is_expected.to eql :induction_training_required }
        end
      end

      context "for Core Induction Programme ECTs" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_duplicate_profile).training_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_active_flags).training_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_active_flags).training_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "with no QTS recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_no_qts).training_eligibility_state }
          it { is_expected.to eql :not_qualified }
        end

        context "found to be exempt from the requirement for a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_exempt_from_induction).training_eligibility_state }
          it { is_expected.to eql :exempt_from_induction }
        end

        context "found to have completed a previous statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_previous_induction).training_eligibility_state }
          it { is_expected.to eql :previous_induction }
        end

        context "found to have already participated in a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_previous_participation).training_eligibility_state }
          it { is_expected.to eql :previous_participation }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_cip_no_tra_record).training_eligibility_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_cip_no_eligibility_checks).training_eligibility_state }
          it { is_expected.to eql :checks_not_complete }
        end

        context "made to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_cip_eligible).training_eligibility_state }
          it { is_expected.to eql :induction_training_required }
        end

        context "found to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_cip).training_eligibility_state }
          it { is_expected.to eql :induction_training_required }
        end
      end

      context "for ECF Mentors" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: mentor_ineligible_duplicate_profile).training_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: mentor_manual_check_active_flags).training_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: mentor_ineligible_active_flags).training_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "made to be eligible for FIP mentor training" do
          subject { described_class.call(participant_profile: mentor_eligible).training_eligibility_state }
          it { is_expected.to eql :mentor_training_available }
        end

        context "found to be eligible for FIP mentor training" do
          subject { described_class.call(participant_profile: mentor).training_eligibility_state }
          it { is_expected.to eql :mentor_training_available }
        end
      end
    end

    context "FIP funding eligibility" do
      context "for Full Induction Programme ECTs" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_duplicate_profile).fip_funding_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        # TODO: :secondary_profile

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "with no induction start date recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_no_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :no_induction_start }
        end

        context "with no QTS recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_no_qts).fip_funding_eligibility_state }
          it { is_expected.to eql :not_qualified }
        end

        context "found to be exempt from the requirement for a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_exempt_from_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :exempt_from_induction }
        end

        context "found to have completed a previous statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :previous_induction }
        end

        context "found to have already participated in a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_participation).fip_funding_eligibility_state }
          it { is_expected.to eql :previous_participation }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_fip_no_tra_record).fip_funding_eligibility_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_fip_no_eligibility_checks).fip_funding_eligibility_state }
          it { is_expected.to eql :checks_not_complete }
        end

        context "TRA record not found with the provided details", skip: "uplift not taken into account" do
          subject { described_class.call(participant_profile: ect_on_fip_no_uplift).fip_funding_eligibility_state }
          it { is_expected.to eql :no_uplift }
        end

        context "made to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_fip_eligible).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_fip_funding }
        end

        context "found to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_fip).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_fip_funding }
        end
      end

      context "for Core Induction Programme ECTs" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_duplicate_profile).fip_funding_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        # TODO: :secondary_profile

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "with no induction start date recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_no_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :no_induction_start }
        end

        context "with no QTS recorded in TRA Records" do
          subject { described_class.call(participant_profile: ect_on_cip_manual_check_no_qts).fip_funding_eligibility_state }
          it { is_expected.to eql :not_qualified }
        end

        context "found to be exempt from the requirement for a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_exempt_from_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :exempt_from_induction }
        end

        context "found to have completed a previous statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_previous_induction).fip_funding_eligibility_state }
          it { is_expected.to eql :previous_induction }
        end

        context "found to have already participated in a statutory induction" do
          subject { described_class.call(participant_profile: ect_on_cip_ineligible_previous_participation).fip_funding_eligibility_state }
          it { is_expected.to eql :previous_participation }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_cip_no_tra_record).fip_funding_eligibility_state }
          it { is_expected.to eql :tra_record_not_found }
        end

        context "TRA record not found with the provided details" do
          subject { described_class.call(participant_profile: ect_on_cip_no_eligibility_checks).fip_funding_eligibility_state }
          it { is_expected.to eql :checks_not_complete }
        end

        context "TRA record not found with the provided details", skip: "uplift not taken into account" do
          subject { described_class.call(participant_profile: ect_on_cip_no_uplift).fip_funding_eligibility_state }
          it { is_expected.to eql :no_uplift }
        end

        context "made to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_cip_eligible).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_fip_funding }
        end

        context "found to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: ect_on_cip).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_fip_funding }
        end
      end

      context "for ECF Mentors" do
        context "found to be a duplicate of another CPD Record" do
          subject { described_class.call(participant_profile: mentor_ineligible_duplicate_profile).fip_funding_eligibility_state }
          it { is_expected.to eql :duplicate_profile }
        end

        # TODO: :secondary_profile

        context "with active flags reported in TRA Records" do
          subject { described_class.call(participant_profile: mentor_manual_check_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :active_flags }
        end

        context "with active flags reported in TRA Records found to be valid" do
          subject { described_class.call(participant_profile: mentor_ineligible_active_flags).fip_funding_eligibility_state }
          it { is_expected.to eql :not_allowed }
        end

        context "made to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: mentor_eligible).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_mentor_funding }
        end

        context "found to be eligible for ECF induction training" do
          subject { described_class.call(participant_profile: mentor).fip_funding_eligibility_state }
          it { is_expected.to eql :eligible_for_mentor_funding }
        end
      end
    end

    context "training state" do
      context "for Full Induction Programme ECTs" do
        context "who has been withdrawn by a training provider" do
          subject { described_class.call(participant_profile: ect_on_fip_withdrawn).training_state }
          it { is_expected.to eql :withdrawn_training }
        end

        context "who has been withdrawn by a school" do
          subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_programme).training_state }
          it { is_expected.to eql :withdrawn_programme }
        end

        context "who has been deferred by a training provider" do
          subject { described_class.call(participant_profile: ect_on_fip_deferred).training_state }
          it { is_expected.to eql :deferred_training }
        end

        context "who has been completed their induction training" do
          subject { described_class.call(participant_profile: ect_on_fip_completed).training_state }
          it { is_expected.to eql :completed_training }
        end

        context "who transferred to another training provider", skip: "needs past induction records" do
          subject { described_class.call(participant_profile: :ect_on_fip_changed_provider).training_state }
          it { is_expected.to eql :no_longer_involved }
        end

        context "who transferred to another training provider" do
          subject { described_class.call(participant_profile: ect_on_fip_leaving).training_state }
          it { is_expected.to eql :leaving }
        end

        context "who is ready for training or is being trained" do
          subject { described_class.call(participant_profile: ect_on_fip).training_state }
          it { is_expected.to eql :registered_for_fip_training }
        end
      end

      context "for Core Induction Programme ECTs" do
        context "who has been withdrawn by a training provider" do
          subject { described_class.call(participant_profile: ect_on_cip_withdrawn).training_state }
          it { is_expected.to eql :withdrawn_training }
        end

        context "who has been withdrawn by a school" do
          subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_programme).training_state }
          it { is_expected.to eql :withdrawn_programme }
        end

        context "who has been deferred by a training provider" do
          subject { described_class.call(participant_profile: ect_on_cip_deferred).training_state }
          it { is_expected.to eql :deferred_training }
        end

        context "who has been completed their induction training" do
          subject { described_class.call(participant_profile: ect_on_cip_completed).training_state }
          it { is_expected.to eql :completed_training }
        end

        context "who transferred to another training provider" do
          subject { described_class.call(participant_profile: ect_on_cip_leaving).training_state }
          it { is_expected.to eql :leaving }
        end

        context "who is ready for training or is being trained" do
          subject { described_class.call(participant_profile: ect_on_cip).training_state }
          it { is_expected.to eql :registered_for_cip_training }
        end
      end

      context "for ECF Mentors" do
        context "who has been withdrawn by a training provider" do
          subject { described_class.call(participant_profile: mentor_withdrawn).training_state }
          it { is_expected.to eql :withdrawn_training }
        end

        context "who has been withdrawn by a school" do
          subject { described_class.call(participant_profile: mentor_withdrawn_from_programme).training_state }
          it { is_expected.to eql :withdrawn_programme }
        end

        context "who has been deferred by a training provider" do
          subject { described_class.call(participant_profile: mentor_deferred).training_state }
          it { is_expected.to eql :deferred_training }
        end

        context "who has been completed their induction training" do
          subject { described_class.call(participant_profile: mentor_completed).training_state }
          it { is_expected.to eql :completed_training }
        end

        context "who transferred to another training provider", skip: "needs past induction records" do
          subject { described_class.call(participant_profile: :mentor_changed_provider).training_state }
          it { is_expected.to eql :no_longer_involved }
        end

        context "who transferred to another training provider" do
          subject { described_class.call(participant_profile: mentor_leaving).training_state }
          it { is_expected.to eql :leaving }
        end

        context "who is ready for training or is being trained" do
          subject { described_class.call(participant_profile: mentor).training_state }
          it { is_expected.to eql :registered_for_mentor_training }
        end
      end
    end

    context "record state" do
      context "for Core Induction Programme ECTs" do
        context "who is currently being trained" do
          subject { described_class.call(participant_profile: ect_on_cip).record_state }
          it { is_expected.to eql :registered_for_cip_training }
        end

        context "who has been withdrawn by their last lead provider" do
          subject { described_class.call(participant_profile: ect_on_cip_withdrawn).record_state }
          it { is_expected.to eql :withdrawn_training }
        end

        context "who has been deferred by their last lead provider" do
          subject { described_class.call(participant_profile: ect_on_cip_deferred).record_state }
          it { is_expected.to eql :deferred_training }
        end

        context "who has been withdrawn by their last school" do
          subject { described_class.call(participant_profile: ect_on_cip_withdrawn_from_programme).record_state }
          it { is_expected.to eql :withdrawn_programme }
        end
      end

      context "for Full Induction Programme ECTs" do
        context "and a request for details email has been submitted" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_submitted).record_state }
          it { is_expected.to eql :request_for_details_submitted }
        end

        context "and a request for details email has failed" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_failed).record_state }
          it { is_expected.to eql :request_for_details_failed }
        end

        context "and a request for details email has been delivered" do
          subject { described_class.call(participant_profile: ect_on_fip_details_request_delivered).record_state }
          it { is_expected.to eql :request_for_details_delivered }
        end

        context "who was registered at a sparsity uplift school" do
          subject { described_class.call(participant_profile: ect_on_fip_sparsity_uplift).record_state }
          it { is_expected.to eql :registered_for_fip_training }
        end

        context "who was registered at a pupil premium uplift school" do
          subject { described_class.call(participant_profile: ect_on_fip_pupil_premium_uplift).record_state }
          it { is_expected.to eql :registered_for_fip_training }
        end

        context "who needs their active flags checking" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_active_flags).record_state }
          it { is_expected.to eql :active_flags }
        end

        context "who potentially has a different TRN on the TRA Record" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_different_trn).record_state }
          it { is_expected.to eql :different_trn }
        end

        context "who has no induction data yet" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_no_induction).record_state }
          it { is_expected.to eql :no_induction_start }
        end

        context "who does not have QTS yet" do
          subject { described_class.call(participant_profile: ect_on_fip_manual_check_no_qts).record_state }
          it { is_expected.to eql :not_qualified }
        end

        context "who is ineligible because the active flags have been confirmed" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_active_flags).record_state }
          it { is_expected.to eql :not_allowed }
        end

        context "who is ineligible because they have a duplicate profile" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_duplicate_profile).record_state }
          it { is_expected.to eql :duplicate_profile }
        end

        context "who is ineligible because they are exempt from induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_exempt_from_induction).record_state }
          it { is_expected.to eql :exempt_from_induction }
        end

        context "who is ineligible because they have a previous induction" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_induction).record_state }
          it { is_expected.to eql :previous_induction }
        end

        context "who is ineligible because they have a previous participation" do
          subject { described_class.call(participant_profile: ect_on_fip_ineligible_previous_participation).record_state }
          it { is_expected.to eql :previous_participation }
        end

        context "who is currently being trained" do
          subject { described_class.call(participant_profile: ect_on_fip).record_state }
          it { is_expected.to eql :registered_for_fip_training }
        end

        context "who has been withdrawn by their last lead provider" do
          subject { described_class.call(participant_profile: ect_on_fip_withdrawn).record_state }
          it { is_expected.to eql :withdrawn_training }
        end

        context "who has been deferred by their last lead provider" do
          subject { described_class.call(participant_profile: ect_on_fip_deferred).record_state }
          it { is_expected.to eql :deferred_training }
        end

        context "who has been withdrawn by their last school" do
          subject { described_class.call(participant_profile: ect_on_fip_withdrawn_from_programme).record_state }
          it { is_expected.to eql :withdrawn_programme }
        end
      end
    end
  end
end
