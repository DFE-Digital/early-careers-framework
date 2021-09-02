# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ValidationRetryJob" do
  let(:participant_data) do
    {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      nino: "",
    }
  end
  let!(:validation_data) do
    create(:ecf_participant_validation_data,
           trn: participant_data[:trn],
           full_name: participant_data[:full_name],
           date_of_birth: participant_data[:date_of_birth],
           nino: participant_data[:nino],
           api_failure: true)
  end

  describe "#perform" do
    context "when the API is working" do
      before do
        validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
        allow(validator).to receive(:validate)
                              .with(participant_data)
                              .and_return({ trn: participant_data[:trn], qts: true, active_alert: false })
      end

      it "rechecks the eligibility" do
        # Given the teacher profile has no TRN
        validation_data.participant_profile.teacher_profile.update!(trn: nil)

        ValidationRetryJob.new.perform
        expect(validation_data.reload.api_failure).to be false
        expect(validation_data.participant_profile.ecf_participant_eligibility).to be_present
        expect(validation_data.participant_profile.ecf_participant_eligibility.status).to eql "matched"
        expect(validation_data.participant_profile.teacher_profile.trn).to eql "1234567"
      end

      it "does not update the TRN when a different one is present" do
        # Given the teacher profile has a different TRN
        validation_data.participant_profile.teacher_profile.update!(trn: "0123456")

        ValidationRetryJob.new.perform
        expect(validation_data.reload.api_failure).to be false
        expect(validation_data.participant_profile.ecf_participant_eligibility).to be_present
        expect(validation_data.participant_profile.ecf_participant_eligibility.status).to eql "manual_check"
        expect(validation_data.participant_profile.teacher_profile.trn).to eql "0123456"
      end
    end

    context "when the API is not working" do
      before do
        validator = class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true)
        allow(validator).to receive(:validate)
                              .with(participant_data)
                              .and_raise(StandardError)
      end

      it "does not change the record" do
        ValidationRetryJob.new.perform
        expect(validation_data.reload.api_failure).to be true
        expect(validation_data.participant_profile.ecf_participant_eligibility).to be_nil
      end
    end
  end
end
