# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState, :with_default_schedules do
  let(:scenarios) { NewSeeds::Scenarios::Participants::TrainingRecordStates.new }

  let!(:current_school) { nil }

  subject(:determined_state) do
    TrainingRecordState.refresh

    described_class.call(participant_profile:, school: current_school)
  end

  shared_examples "determines states as" do |validation_state, training_eligibility_state, fip_funding_eligibility_state, training_state, record_state|
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

    it "Each StatusTag has a language file entry for the record_state of \"#{record_state}\"" do
      expect(I18n.t("status_tags.admin_participant_status").keys).to include record_state&.to_sym
    end

    it "StatusTags::AppropriateBodyParticipantStatusTag has a language file entry for the record_state of \"#{record_state}\"" do
      expect(I18n.t("status_tags.appropriate_body_participant_status").keys).to include record_state&.to_sym
    end

    it "StatusTags::DeliveryPartnerParticipantStatusTag has a language file entry for the record_state of \"#{record_state}\"" do
      expect(I18n.t("status_tags.delivery_partner_participant_status").keys).to include record_state&.to_sym
    end

    it "StatusTags::SchoolParticipantStatusTag has a language file entry for the record_state of \"#{record_state}\"" do
      expect(I18n.t("status_tags.school_participant_status").keys).to include record_state&.to_sym
    end

    it "StatusTags::SchoolParticipantStatusTag has a detailed language file entry for the record_state of \"#{record_state}\"" do
      expect(I18n.t("status_tags.school_participant_status_detailed").keys).to include record_state&.to_sym
    end
  end

  describe "#call" do
    context "when not called with a ParticipantProfile" do
      subject { described_class.call(participant_profile: TeacherProfile.new).record_state.participant_profile }

      it "Raises an ArgumentError" do
        expect { subject.participant_profile }.to raise_error ArgumentError
      end
    end

    context "when not called with an InductionRecord" do
      subject { described_class.call(participant_profile: scenarios.ect_on_cip.participant_profile, induction_record: TeacherProfile.new).record_state.participant_profile }

      it "Raises an ArgumentError" do
        expect { subject.participant_profile }.to raise_error ArgumentError
      end
    end

    context "when a FIP ECT" do
      context "and is awaiting validation" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_validation.participant_profile }

        include_examples "determines states as",
                         "validation_not_started",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.ect_on_fip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "tra_record_not_found"
      end

      context "and the school is eligible for sparsity uplift" do
        let!(:participant_profile) { scenarios.ect_on_fip_sparsity_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school is eligible for pupil premium uplift" do
        let!(:participant_profile) { scenarios.ect_on_fip_pupil_premium_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school has no eligible uplifts" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_fip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "different_trn"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_no_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "no_induction_start",
                         "registered_for_fip_training",
                         "no_induction_start"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_qualified",
                         "not_qualified",
                         "active_fip_training",
                         "not_qualified"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_fip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.ect_on_fip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "duplicate_profile",
                         "duplicate_profile",
                         "active_fip_training",
                         "duplicate_profile"
      end

      context "and they are exempt from induction" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_exempt_from_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "exempt_from_induction",
                         "exempt_from_induction",
                         "active_fip_training",
                         "exempt_from_induction"
      end

      context "and they have a previous induction recorded" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_previous_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "previous_induction",
                         "previous_induction",
                         "active_fip_training",
                         "previous_induction"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.ect_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school has not yet reported the training providers" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_partnership.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training_no_partner",
                         "eligible_for_fip_funding",
                         "registered_for_fip_no_partner",
                         "registered_for_fip_no_partner"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.ect_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_fip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.ect_on_fip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.ect_on_fip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "completed_training",
                         "completed_training"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.fip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "active_fip_training",
                           "active_fip_training"
        end
      end
    end

    context "when a CIP ECT" do
      context "and is awaiting validation" do
        let!(:participant_profile) { scenarios.ect_on_cip_no_validation.participant_profile }

        include_examples "determines states as",
                         "validation_not_started",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.ect_on_cip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.ect_on_cip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_cip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_cip_training",
                         "different_trn"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_no_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "no_induction_start",
                         "registered_for_cip_training",
                         "registered_for_cip_training"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_qualified",
                         "not_qualified",
                         "active_cip_training",
                         "not_qualified"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_cip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.ect_on_cip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "duplicate_profile",
                         "duplicate_profile",
                         "active_cip_training",
                         "duplicate_profile"
      end

      context "and they are exempt from induction" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_exempt_from_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "exempt_from_induction",
                         "exempt_from_induction",
                         "active_cip_training",
                         "exempt_from_induction"
      end

      context "and they have a previous induction recorded" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_previous_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "previous_induction",
                         "previous_induction",
                         "active_cip_training",
                         "previous_induction"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.ect_on_cip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.ect_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.ect_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_cip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.ect_on_cip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.ect_on_cip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "completed_training",
                         "completed_training"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.cip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "active_cip_training",
                           "active_cip_training"
        end
      end
    end

    context "when a FIP Mentor" do
      context "and is awaiting validation" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_validation.participant_profile }

        include_examples "determines states as",
                         "validation_not_started",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.mentor_on_fip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_fip_mentoring",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "different_trn"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.mentor_on_fip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_fip_mentoring",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.mentor_on_fip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_fip_mentoring",
                         "ineligible_secondary"
      end

      context "and they have a previous participation recorded" do
        let!(:participant_profile) { scenarios.mentor_ero_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_ero",
                         "active_fip_mentoring_ero",
                         "ineligible_ero"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_ero_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring_ero",
                         "active_fip_mentoring_ero"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_fip_mentoring",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let!(:participant_profile) { scenarios.mentor_on_fip_profile_duplicity_primary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding_primary",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let!(:participant_profile) { scenarios.mentor_on_fip_profile_duplicity_secondary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_fip_mentoring",
                         "ineligible_secondary"
      end

      context "and the school has not yet reported the training providers" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_partnership.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training_no_partner",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring_no_partner",
                         "active_fip_mentoring_no_partner"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.mentor_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and they are currently not mentoring" do
        let!(:participant_profile) { scenarios.mentor_on_fip_with_no_mentees.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_yet_mentoring",
                         "eligible_for_mentor_funding",
                         "not_yet_mentoring_fip",
                         "not_yet_mentoring_fip"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_fip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_fip_mentoring",
                         "active_fip_mentoring"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.mentor_on_fip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.mentor_on_fip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "completed_training",
                         "completed_training"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.fip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_fip_mentoring",
                           "active_fip_mentoring"
        end
      end
    end

    context "when a CIP Mentor" do
      context "and is awaiting validation" do
        let!(:participant_profile) { scenarios.mentor_on_cip_no_validation.participant_profile }

        include_examples "determines states as",
                         "validation_not_started",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.mentor_on_cip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.mentor_on_cip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_cip_mentoring",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "different_trn"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.mentor_on_cip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_cip_mentoring",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.mentor_on_cip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they have a previous participation recorded" do
        let!(:participant_profile) { scenarios.mentor_ero_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_ero",
                         "active_cip_mentoring_ero",
                         "active_cip_mentoring_ero"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_ero_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring_ero",
                         "active_cip_mentoring_ero"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.mentor_on_cip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_cip_mentoring",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let!(:participant_profile) { scenarios.mentor_on_cip_profile_duplicity_primary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding_primary",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let!(:participant_profile) { scenarios.mentor_on_cip_profile_duplicity_secondary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.mentor_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they are currently not mentoring" do
        let!(:participant_profile) { scenarios.mentor_on_cip_with_no_mentees.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_yet_mentoring",
                         "eligible_for_mentor_funding",
                         "not_yet_mentoring_cip",
                         "not_yet_mentoring_cip"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_cip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_cip_mentoring",
                         "active_cip_mentoring"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.mentor_on_cip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.mentor_on_cip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "completed_training",
                         "completed_training"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.cip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_cip_mentoring",
                           "active_cip_mentoring"
        end
      end
    end
  end
end
