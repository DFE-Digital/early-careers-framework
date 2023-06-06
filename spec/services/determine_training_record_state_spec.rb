# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineTrainingRecordState, :with_default_schedules do
  let(:scenarios) { NewSeeds::Scenarios::Participants::TrainingRecordStates.new }

  let!(:current_school) { nil }

  subject(:determined_state) do
    described_class.call(participant_profile:, school: current_school)
  end

  shared_examples "determines states as" do |validation_state, training_eligibility_state, fip_funding_eligibility_state, mentoring_state, training_state, record_state|
    it %(states are determined as expected and each StatusTag has a language file entry for the record_state of "#{record_state}") do
      expect(determined_state.validation_state).to eq validation_state
      expect(determined_state.training_eligibility_state).to eq training_eligibility_state
      expect(determined_state.fip_funding_eligibility_state).to eq fip_funding_eligibility_state
      expect(determined_state.mentoring_state).to eq mentoring_state
      expect(determined_state.training_state).to eq training_state
      expect(determined_state.record_state).to eq record_state

      expect(I18n.t("status_tags.admin_participant_status").keys).to include record_state&.to_sym
      expect(I18n.t("status_tags.appropriate_body_participant_status").keys).to include record_state&.to_sym
      expect(I18n.t("status_tags.delivery_partner_participant_status").keys).to include record_state&.to_sym
      expect(I18n.t("status_tags.school_participant_status").keys).to include record_state&.to_sym
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
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.ect_on_fip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.ect_on_fip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "tra_record_not_found"
      end

      context "and the school is eligible for sparsity uplift" do
        let!(:participant_profile) { scenarios.ect_on_fip_sparsity_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school is eligible for pupil premium uplift" do
        let!(:participant_profile) { scenarios.ect_on_fip_pupil_premium_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school has no eligible uplifts" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_uplift.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "different_trn"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_no_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "no_induction_start",
                         "not_a_mentor",
                         "registered_for_fip_training",
                         "no_induction_start"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.ect_on_fip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_qualified",
                         "not_qualified",
                         "not_a_mentor",
                         "active_fip_training",
                         "not_qualified"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "not_a_mentor",
                         "active_fip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.ect_on_fip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "duplicate_profile",
                         "duplicate_profile",
                         "not_a_mentor",
                         "active_fip_training",
                         "duplicate_profile"
      end

      context "and they are exempt from induction" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_exempt_from_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "exempt_from_induction",
                         "exempt_from_induction",
                         "not_a_mentor",
                         "active_fip_training",
                         "exempt_from_induction"
      end

      context "and they have a previous induction recorded" do
        let!(:participant_profile) { scenarios.ect_on_fip_ineligible_previous_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "previous_induction",
                         "previous_induction",
                         "not_a_mentor",
                         "active_fip_training",
                         "previous_induction"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "active_fip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.ect_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the school has not yet reported the training providers" do
        let!(:participant_profile) { scenarios.ect_on_fip_no_partnership.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "registered_for_fip_no_partner",
                         "registered_for_fip_no_partner"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.ect_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_fip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.ect_on_fip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.ect_on_fip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.ect_on_fip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "completed_training",
                         "completed_training"
      end

      context "and the cohort has been changed" do
        let!(:participant_profile) { scenarios.ect_on_fip_after_cohort_transfer.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "and the mentor has been changed" do
        let!(:participant_profile) { scenarios.ect_on_fip_after_mentor_change.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_fip_training",
                         "active_fip_training"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.fip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.ect_on_fip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
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
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.ect_on_cip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.ect_on_cip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.ect_on_cip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "not_a_mentor",
                         "active_cip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_cip_training",
                         "different_trn"
      end

      context "and no induction start date has been recorded by the AB yet" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_no_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "no_induction_start",
                         "not_a_mentor",
                         "registered_for_cip_training",
                         "registered_for_cip_training"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.ect_on_cip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_qualified",
                         "not_qualified",
                         "not_a_mentor",
                         "active_cip_training",
                         "not_qualified"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "not_a_mentor",
                         "active_cip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.ect_on_cip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "duplicate_profile",
                         "duplicate_profile",
                         "not_a_mentor",
                         "active_cip_training",
                         "duplicate_profile"
      end

      context "and they are exempt from induction" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_exempt_from_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "exempt_from_induction",
                         "exempt_from_induction",
                         "not_a_mentor",
                         "active_cip_training",
                         "exempt_from_induction"
      end

      context "and they have a previous induction recorded" do
        let!(:participant_profile) { scenarios.ect_on_cip_ineligible_previous_induction.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "previous_induction",
                         "previous_induction",
                         "not_a_mentor",
                         "active_cip_training",
                         "previous_induction"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.ect_on_cip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "not_a_mentor",
                         "active_cip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.ect_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.ect_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.ect_on_cip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "active_cip_training",
                         "active_cip_training"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_training",
                         "withdrawn_training"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.ect_on_cip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "deferred_training",
                         "deferred_training"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.ect_on_cip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.ect_on_cip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_induction_training",
                         "eligible_for_fip_funding",
                         "not_a_mentor",
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
                           "not_a_mentor",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.ect_on_cip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_induction_training",
                           "eligible_for_fip_funding",
                           "not_a_mentor",
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
                         "active_mentoring",
                         "registered_for_fip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.mentor_on_fip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.mentor_on_fip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "different_trn"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.mentor_on_fip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.mentor_on_fip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.mentor_on_fip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they have a previous participation recorded" do
        let!(:participant_profile) { scenarios.mentor_ero_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_ero",
                         "active_mentoring_ero",
                         "registered_for_fip_training",
                         "active_mentoring_ero"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_ero_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring_ero",
                         "registered_for_fip_training",
                         "active_mentoring_ero"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_fip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let!(:participant_profile) { scenarios.mentor_on_fip_profile_duplicity_primary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding_primary",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let!(:participant_profile) { scenarios.mentor_on_fip_profile_duplicity_secondary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and the school has not yet reported the training providers" do
        let!(:participant_profile) { scenarios.mentor_on_fip_no_partnership.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_no_partner",
                         "active_mentoring"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.mentor_on_fip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they are currently not mentoring" do
        let!(:participant_profile) { scenarios.mentor_on_fip_with_no_mentees.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_yet_mentoring",
                         "eligible_for_mentor_funding",
                         "not_yet_mentoring",
                         "registered_for_fip_training",
                         "not_yet_mentoring"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_training",
                         "active_mentoring"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_fip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_fip_training",
                         "active_mentoring"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_training",
                         "active_mentoring"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.mentor_on_fip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "deferred_training",
                         "active_mentoring"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.mentor_on_fip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their mentor training" do
        let!(:participant_profile) { scenarios.mentor_on_fip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "completed_training",
                         "active_mentoring"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.fip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.mentor_on_fip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "registered_for_fip_training",
                           "active_mentoring"
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
                         "active_mentoring",
                         "registered_for_cip_training",
                         "validation_not_started"
      end

      context "and a request for details has been submitted" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_submitted.participant_profile }

        include_examples "determines states as",
                         "request_for_details_submitted",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "request_for_details_submitted"
      end

      context "and a request for details has failed" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_failed.participant_profile }

        include_examples "determines states as",
                         "request_for_details_failed",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "request_for_details_failed"
      end

      context "and a request for details has been delivered" do
        let!(:participant_profile) { scenarios.mentor_on_cip_details_request_delivered.participant_profile }

        include_examples "determines states as",
                         "request_for_details_delivered",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "request_for_details_delivered"
      end

      context "and the validation API has failed" do
        let!(:participant_profile) { scenarios.mentor_on_cip_validation_api_failure.participant_profile }

        include_examples "determines states as",
                         "internal_error",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "internal_error"
      end

      context "and no TRA record could be found" do
        let!(:participant_profile) { scenarios.mentor_on_cip_no_tra_record.participant_profile }

        include_examples "determines states as",
                         "tra_record_not_found",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "tra_record_not_found"
      end

      context "and active flags have been found on the TRA record" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "active_flags",
                         "active_flags",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_flags"
      end

      context "and a different TRN was identified with the details provided" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_different_trn.participant_profile }

        include_examples "determines states as",
                         "different_trn",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "different_trn"
      end

      context "and they do not have QTS on record" do
        let!(:participant_profile) { scenarios.mentor_on_cip_manual_check_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they do not have QTS on record but had been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible_no_qts.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and the active flags have been investigated and found to be relevant" do
        let!(:participant_profile) { scenarios.mentor_on_cip_ineligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_allowed",
                         "not_allowed",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "not_allowed"
      end

      context "and the active flags have been investigated and found to be irrelevant" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible_active_flags.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and a duplicate profile has been found but no duplicity is recorded" do
        let!(:participant_profile) { scenarios.mentor_on_cip_ineligible_duplicate_profile.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they have a previous participation recorded" do
        let!(:participant_profile) { scenarios.mentor_ero_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_ero",
                         "active_mentoring_ero",
                         "registered_for_cip_training",
                         "active_mentoring_ero"
      end

      context "and they have a previous participation recorded and have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_ero_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring_ero",
                         "registered_for_cip_training",
                         "active_mentoring_ero"
      end

      context "and they have had no eligibility checks performed yet" do
        let!(:participant_profile) { scenarios.mentor_on_cip_no_eligibility_checks.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "checks_not_complete",
                         "checks_not_complete",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "checks_not_complete"
      end

      context "and they have been made eligible by DfE" do
        let!(:participant_profile) { scenarios.mentor_on_cip_eligible.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they have a duplicate profile but this is the primary one" do
        let!(:participant_profile) { scenarios.mentor_on_cip_profile_duplicity_primary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding_primary",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they have a duplicate profile and this is the secondary one" do
        let!(:participant_profile) { scenarios.mentor_on_cip_profile_duplicity_secondary.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "ineligible_secondary",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they are active" do
        let!(:participant_profile) { scenarios.mentor_on_cip.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they are currently not mentoring" do
        let!(:participant_profile) { scenarios.mentor_on_cip_with_no_mentees.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "not_yet_mentoring",
                         "eligible_for_mentor_funding",
                         "not_yet_mentoring",
                         "registered_for_cip_training",
                         "not_yet_mentoring"
      end

      context "and they have been withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_training",
                         "active_mentoring"
      end

      context "and they have been re-enrolled after being withdrawn by a training provider through the API" do
        let!(:participant_profile) { scenarios.mentor_on_cip_enrolled_after_withdraw.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "registered_for_cip_training",
                         "active_mentoring"
      end

      context "and they were withdrawn before an induction record was created for them" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn_no_induction_record.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_training",
                         "active_mentoring"
      end

      context "and their training has been deferred" do
        let!(:participant_profile) { scenarios.mentor_on_cip_deferred.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "deferred_training",
                         "active_mentoring"
      end

      context "and they have been withdrawn from the programme" do
        let!(:participant_profile) { scenarios.mentor_on_cip_withdrawn_from_programme.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "withdrawn_programme",
                         "withdrawn_programme"
      end

      context "and they have completed their induction training" do
        let!(:participant_profile) { scenarios.mentor_on_cip_completed.participant_profile }

        include_examples "determines states as",
                         "valid",
                         "eligible_for_mentor_training",
                         "eligible_for_mentor_funding",
                         "active_mentoring",
                         "completed_training",
                         "active_mentoring"
      end

      context "in transfer scenario" do
        let!(:current_school) { scenarios.cip_school.school }

        context "and they are leaving their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_leaving.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "leaving",
                           "leaving"
        end

        context "and they have left their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_left.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "left",
                           "left"
        end

        context "and they are transferring from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_transferring.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "leaving",
                           "leaving"
        end

        context "and they have transferred from their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_transferred.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "left",
                           "left"
        end

        context "and they are joining their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_joining.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "joining",
                           "joining"
        end

        context "and they have joined their current school" do
          let!(:participant_profile) { scenarios.mentor_on_cip_joined.participant_profile }

          include_examples "determines states as",
                           "valid",
                           "eligible_for_mentor_training",
                           "eligible_for_mentor_funding",
                           "active_mentoring",
                           "registered_for_cip_training",
                           "active_mentoring"
        end
      end
    end
  end
end
