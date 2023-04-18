# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::FindByTrainingRecordState, :with_training_record_state_examples do
  subject(:results) { Participants::FindByTrainingRecordState.call(ParticipantProfile, record_state).all }

  let!(:all_participants) do
    [
      ect_on_fip_manual_check_different_trn,
      ect_on_fip_details_request_submitted,
      ect_on_fip_details_request_failed,
      ect_on_fip_details_request_delivered,
      ect_on_fip_no_validation,
      ect_on_fip_validation_api_failure,
      ect_on_fip_no_tra_record,
      ect_on_fip_sparsity_uplift, # valid
      ect_on_fip_pupil_premium_uplift, # valid
      ect_on_fip_no_uplift, # valid
      ect_on_fip_manual_check_active_flags,
    ]
  end

  describe "#call" do
    context "when looking for profiles that have different TRNs" do
      let(:record_state) { :different_trn }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_manual_check_different_trn]
      end
    end

    context "when looking for profiles where the request for details email has been submitted to GOV UK Notify" do
      let(:record_state) { :request_for_details_submitted }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_details_request_submitted]
      end
    end

    context "when looking for profiles where the request for details email has failed to be delivered to" do
      let(:record_state) { :request_for_details_failed }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_details_request_failed]
      end
    end

    context "when looking for profiles where the request for details email has been delivered to" do
      let(:record_state) { :request_for_details_delivered }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_details_request_delivered]
      end
    end

    context "when looking for profiles that are awaiting the validation checks" do
      let(:record_state) { :validation_not_started }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_no_validation]
      end
    end

    context "when looking for profiles where the DQT API failed" do
      let(:record_state) { :internal_error }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_validation_api_failure]
      end
    end

    context "when looking for profiles where no TRA record was found" do
      let(:record_state) { :tra_record_not_found }

      it "finds the correct profile" do
        is_expected.to match [ect_on_fip_no_tra_record]
      end
    end

    context "when looking for profiles where the data provided was determined to be valid" do
      let(:record_state) { :valid }

      it "finds all the profiles that have successfully validated" do
        is_expected.to match [
          ect_on_fip_sparsity_uplift,
          ect_on_fip_pupil_premium_uplift,
          ect_on_fip_no_uplift,
          ect_on_fip_manual_check_active_flags,
        ]
      end
    end

    context "when looking for profiles where active flags have been found on the TRA record" do
      let(:record_state) { :active_flags }

      it "finds the correct profile" do
        is_expected.to match [
          ect_on_fip_manual_check_active_flags,
        ]
      end
    end
  end
end
