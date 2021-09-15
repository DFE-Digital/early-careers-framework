# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidateParticipant do
  describe ".call" do
    subject(:service) { described_class }
    let(:school_cohort) { create(:school_cohort) }
    let(:teacher_profile) { create(:teacher_profile, school: school_cohort.school, trn: nil) }
    let(:participant_profile) { create(:participant_profile, :ect, school_cohort: school_cohort, teacher_profile: teacher_profile) }

    let(:request_data) do
      {
        trn: "1234567",
        name: "Karen Hastings",
        date_of_birth: Date.new(1993, 11, 16),
        national_insurance_number: "QQ123456A",
      }
    end

    let(:validation_request) do
      {
        trn: request_data[:trn],
        full_name: request_data[:name],
        date_of_birth: request_data[:date_of_birth],
        nino: request_data[:national_insurance_number],
        config: {},
      }
    end

    let(:validation_response) do
      {
        trn: "1234567",
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
      }
    end

    let(:manual_check_record) { create(:ecf_participant_eligibility, :manual_check) }
    let(:eligible_record) { create(:ecf_participant_eligibility, :eligible) }

    let(:validation_service) { class_double("ParticipantValidationService").as_stubbed_const(transfer_nested_constants: true) }

    context "when validation data is supplied" do
      it "performs checks using the supplied data" do
        allow(validation_service).to receive(:validate)
          .with(validation_request)
          .and_return(validation_response)

        service.call(participant_profile: participant_profile, validation_data: request_data)
      end
    end

    context "when validation data is not supplied" do
      let(:validation_request) do
        {
          trn: "1234567",
          full_name: "Arthur Askey",
          date_of_birth: Date.new(1965, 1, 17),
          nino: "QQ112233A",
        }
      end

      before do
        participant_profile.create_ecf_participant_validation_data!(validation_request)
      end

      it "performs checks using validation data from the profile" do
        allow(validation_service).to receive(:validate)
          .with(validation_request.merge(config: {}))
          .and_return(validation_response)

        service.call(participant_profile: participant_profile)
      end
    end

    context "when a match is found at the DQT" do
      before do
        allow(validation_service).to receive(:validate)
          .with(validation_request)
          .and_return(validation_response)
      end

      it "returns true" do
        expect(service.call(participant_profile: participant_profile, validation_data: request_data)).to be true
      end

      it "creates an eligibility record for the participant" do
        service.call(participant_profile: participant_profile, validation_data: request_data)
        eligibility = participant_profile.reload.ecf_participant_eligibility
        expect(eligibility).to be_matched_status
      end

      context "when the participant is not eligible" do
        before do
          allow_any_instance_of(described_class).to receive(:store_eligibility_data!)
            .with(validation_response)
            .and_return(manual_check_record)
        end

        it "saves the validation data against the profile" do
          service.call(participant_profile: participant_profile, validation_data: request_data)
          validation_data = participant_profile.reload.ecf_participant_validation_data
          expect(validation_data.trn).to eq request_data[:trn]
          expect(validation_data.full_name).to eq request_data[:name]
          expect(validation_data.date_of_birth).to eq request_data[:date_of_birth]
          expect(validation_data.nino).to eq request_data[:national_insurance_number]
        end
      end

      context "when the participant is eligible" do
        before do
          allow_any_instance_of(described_class).to receive(:store_eligibility_data!)
            .with(validation_response)
            .and_return(eligible_record)
        end

        it "does not save the validation data" do
          service.call(participant_profile: participant_profile, validation_data: request_data)
          expect(participant_profile.reload.ecf_participant_validation_data).to be_nil
        end
      end
    end

    context "when a match is not found at the DQT" do
      before do
        allow(validation_service).to receive(:validate)
          .with(validation_request)
          .and_return(nil)
      end

      it "returns false" do
        result = service.call(participant_profile: participant_profile, validation_data: request_data)
        expect(result).to be false
      end

      it "saves the validation data against the profile" do
        service.call(participant_profile: participant_profile, validation_data: request_data)
        validation_data = participant_profile.reload.ecf_participant_validation_data
        expect(validation_data.trn).to eq request_data[:trn]
        expect(validation_data.full_name).to eq request_data[:name]
        expect(validation_data.date_of_birth).to eq request_data[:date_of_birth]
        expect(validation_data.nino).to eq request_data[:national_insurance_number]
      end

      context "when the save_validation_data_without_match is not set" do
        it "does not save the validation data" do
          service.call(participant_profile: participant_profile, validation_data: request_data,
                       config: { save_validation_data_without_match: false })
          expect(participant_profile.reload.ecf_participant_validation_data).to be_nil
        end
      end
    end

    context "when eligibility data already exists" do
      let!(:existing_eligibility) { create(:ecf_participant_eligibility, :manual_check, participant_profile: participant_profile, previous_participation: true) }

      before do
        allow(validation_service).to receive(:validate)
          .with(validation_request)
          .and_return(validation_response)
      end

      it "updates the eligibility data" do
        service.call(participant_profile: participant_profile, validation_data: request_data)
        expect(existing_eligibility.reload).to be_matched_status
        expect(existing_eligibility.previous_participation).to be false
      end

      it "does not create another eligibility record" do
        expect {
          service.call(participant_profile: participant_profile, validation_data: request_data)
        }.not_to change { ECFParticipantEligibility.count }
      end
    end
  end
end
