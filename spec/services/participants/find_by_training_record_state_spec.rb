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
    it "finds the correct profile when looking for profiles that have different TRNs" do
      aggregate_failures do
        # finds the correct profile
        expect(described_class.call(ParticipantProfile, :different_trn).all).to match [scenarios.ect_on_fip_manual_check_different_trn.participant_profile]

        # when looking for profiles where the request for details email has been submitted to GOV UK Notify
        expect(described_class.call(ParticipantProfile, :request_for_details_submitted).all).to match [scenarios.ect_on_fip_details_request_submitted.participant_profile]

        # when looking for profiles where the request for details email has failed to be delivered to
        expect(described_class.call(ParticipantProfile, :request_for_details_failed).all).to match [scenarios.ect_on_fip_details_request_failed.participant_profile]

        # when looking for profiles where the request for details email has been delivered to
        expect(described_class.call(ParticipantProfile, :request_for_details_delivered).all).to match [scenarios.ect_on_fip_details_request_delivered.participant_profile]

        # when looking for profiles that are awaiting the validation checks
        expect(described_class.call(ParticipantProfile, :validation_not_started).all).to match [scenarios.ect_on_fip_no_validation.participant_profile]

        # when looking for profiles where the DQT API failed
        expect(described_class.call(ParticipantProfile, :tra_record_not_found).all).to match [scenarios.ect_on_fip_no_tra_record.participant_profile]

        # when looking for profiles where no TRA record was found
        expect(described_class.call(ParticipantProfile, :internal_error).all).to match [scenarios.ect_on_fip_validation_api_failure.participant_profile]

        # when looking for profiles where no TRA record was found
        expect(described_class.call(ParticipantProfile, :valid).all).not_to include([
          scenarios.ect_on_fip_manual_check_different_trn.participant_profile,
          scenarios.ect_on_fip_details_request_submitted.participant_profile,
          scenarios.ect_on_fip_details_request_failed.participant_profile,
          scenarios.ect_on_fip_details_request_delivered.participant_profile,
          scenarios.ect_on_fip_no_validation.participant_profile,
          scenarios.ect_on_fip_validation_api_failure.participant_profile,
          scenarios.ect_on_fip_no_tra_record.participant_profile,
        ])

        # :checks_not_complete

        # when looking for profiles where active flags have been found on the TRA record
        expect(described_class.call(ParticipantProfile, :active_flags).all).to match [scenarios.ect_on_fip_manual_check_active_flags.participant_profile]

        # when looking for profiles with ineligible active flags
        expect(described_class.call(ParticipantProfile, :not_allowed).all).to match [scenarios.ect_on_fip_ineligible_active_flags.participant_profile]
      end
    end
  end
end
