# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::FindByTrainingRecordState, :with_default_schedules do
  let(:scenarios) { NewSeeds::Scenarios::Participants::TrainingRecordStates.new }

  let!(:all_participants) do
    [
      scenarios.ect_on_fip_manual_check_different_trn.participant_profile,
      scenarios.ect_on_fip_details_request_submitted.participant_profile,
      scenarios.ect_on_fip_details_request_failed.participant_profile,
      scenarios.ect_on_fip_details_request_delivered.participant_profile,
      scenarios.ect_on_fip_no_validation.participant_profile,
      scenarios.ect_on_fip_validation_api_failure.participant_profile,
      scenarios.ect_on_fip_no_tra_record.participant_profile,
      scenarios.ect_on_fip_sparsity_uplift.participant_profile, # valid
      scenarios.ect_on_fip_pupil_premium_uplift.participant_profile, # valid
      scenarios.ect_on_fip_no_uplift.participant_profile, # valid
      scenarios.ect_on_fip_manual_check_active_flags.participant_profile,
      scenarios.ect_on_fip_ineligible_active_flags.participant_profile,
    ]
  end

  subject(:results) { Participants::FindByTrainingRecordState.call(ParticipantProfile, record_state).all }

  describe "#call" do
    context "when looking for profiles that have different TRNs" do
      let(:record_state) { :different_trn }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_manual_check_different_trn.participant_profile]
      end
    end

    context "when looking for profiles where the request for details email has been submitted to GOV UK Notify" do
      let(:record_state) { :request_for_details_submitted }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_details_request_submitted.participant_profile]
      end
    end

    context "when looking for profiles where the request for details email has failed to be delivered to" do
      let(:record_state) { :request_for_details_failed }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_details_request_failed.participant_profile]
      end
    end

    context "when looking for profiles where the request for details email has been delivered to" do
      let(:record_state) { :request_for_details_delivered }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_details_request_delivered.participant_profile]
      end
    end

    context "when looking for profiles that are awaiting the validation checks" do
      let(:record_state) { :validation_not_started }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_no_validation.participant_profile]
      end
    end

    context "when looking for profiles where the DQT API failed" do
      let(:record_state) { :internal_error }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_validation_api_failure.participant_profile]
      end
    end

    context "when looking for profiles where no TRA record was found" do
      let(:record_state) { :tra_record_not_found }

      it "finds the correct profile" do
        is_expected.to match [scenarios.ect_on_fip_no_tra_record.participant_profile]
      end
    end

    context "when looking for profiles where the data provided was determined to be valid" do
      let(:record_state) { :valid }

      it "finds all the profiles that have successfully validated" do
        is_expected.to_not include [
          scenarios.ect_on_fip_manual_check_different_trn.participant_profile,
          scenarios.ect_on_fip_details_request_submitted.participant_profile,
          scenarios.ect_on_fip_details_request_failed.participant_profile,
          scenarios.ect_on_fip_details_request_delivered.participant_profile,
          scenarios.ect_on_fip_no_validation.participant_profile,
          scenarios.ect_on_fip_validation_api_failure.participant_profile,
          scenarios.ect_on_fip_no_tra_record.participant_profile,
        ]
      end
    end

    # :checks_not_complete

    context "when looking for profiles where active flags have been found on the TRA record" do
      let(:record_state) { :active_flags }

      it "finds the correct profile" do
        is_expected.to match [
          scenarios.ect_on_fip_manual_check_active_flags.participant_profile,
        ]
      end
    end

    context "when looking for profiles where active flags have been found on the TRA record" do
      let(:record_state) { :not_allowed }

      it "finds the correct profile" do
        is_expected.to match [
          scenarios.ect_on_fip_ineligible_active_flags.participant_profile,
        ]
      end
    end
  end
end
