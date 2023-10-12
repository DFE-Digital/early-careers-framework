# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ParticipantValidationForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }

  let(:participant_profile) { create :ect_participant_profile }
  let(:validation_result) { nil }
  let(:eligibility_record) { build :ecf_participant_eligibility, participant_profile: }

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return(validation_result)
    allow(StoreValidationResult).to receive(:call).and_return(eligibility_record)
  end

  describe "#call" do
    subject(:call) { described_class.call(participant_profile, data:) }

    let(:data) do
      {
        trn: "1234567",
        nino: "AB123456C",
        date_of_birth: 20.years.ago,
        full_name: "John Doe",
      }
    end

    context "when no validation data is provided" do
      let(:data) { nil }
      it { is_expected.to be false }
    end

    context "when validation data is provided" do
      it "builds a form with the validation data" do
        expect(described_class).to receive(:build).with(participant_profile, data:)
        call
      end

      it "calls the form" do
        stubbed_form_object = double(described_class)
        allow(described_class).to receive(:build).and_return(stubbed_form_object)
        expect(stubbed_form_object).to receive(:call).once
        call
      end
    end
  end

  describe ".call" do
    subject(:call) { described_class.build(participant_profile, data:).call }

    let(:data) do
      {
        trn: "1234567",
        nino: "AB123456C",
        date_of_birth: 20.years.ago.to_date,
        full_name: "John Doe",
      }
    end

    let(:validation_result) do
      {
        trn: "1234567",
        qts: true,
        active_alert: false,
        previous_participation: false,
        previous_induction: false,
        no_induction: true,
        exempt_from_induction: false,
        induction_start_date: Date.new(2022, 9, 1),
      }
    end

    before do
      allow(ParticipantProfile).to receive(:find).with(participant_profile.id).and_return(participant_profile)
    end

    it "updates eligibility" do
      expect(StoreValidationResult).to receive(:call).with(
        participant_profile:,
        validation_data: {
          trn: data[:trn],
          nino: data[:nino],
          dob: data[:date_of_birth],
          full_name: data[:full_name],
        },
        dqt_response: validation_result,
      ).twice

      expect(Participants::SyncDQTInductionStartDate).to receive(:call).with(
        validation_result[:induction_start_date],
        participant_profile,
      )

      call
    end
  end

  describe "check eligibility!" do
    subject { form.check_eligibility! }

    context "validation result is blank" do
      it { is_expected.to eq :no_match }
    end

    context "there is a duplicate profile and the user is a mentor" do
      let(:validation_result) { { i: "am not blank" } }
      let(:participant_profile) { create :mentor_participant_profile, :secondary_profile }
      let(:eligibility_record) do
        create(
          :ecf_participant_eligibility,
          :secondary_profile_state,
          participant_profile:,
        )
      end

      it {
        is_expected.to eq :secondary_fip_mentor_eligible
      }
    end

    context "previous participation is set" do
      let(:validation_result) { { i: "am not blank" } }
      let(:eligibility_record) do
        create(
          :ecf_participant_eligibility,
          :previous_participation_state,
          participant_profile:,
        )
      end
      it { is_expected.to eq :previous_participation }
    end

    context "the participant is exempt from induction" do
      let(:validation_result) { { i: "am not blank" } }
      let(:eligibility_record) do
        create(
          :ecf_participant_eligibility,
          :exempt_from_induction_state,
          participant_profile:,
        )
      end
      it { is_expected.to eq :exempt_from_induction }
    end
  end

  describe "steps" do
    describe "STEP trn" do
      context "when no_trn flag is not set" do
        it { is_expected.to validate_presence_of(:trn).on(:trn).with_message("Enter your teacher reference number (TRN)") }

        it "validates the TRN has at least 5 digits" do
          form.trn = "RP22/12"
          expect(form).not_to be_valid
          expect(form.errors[:trn]).to include "Teacher reference number must include at least 5 digits"
        end

        it "validates the TRN has at most 7 digits" do
          form.trn = "RP22/1234567"
          expect(form).not_to be_valid
          expect(form.errors[:trn]).to include "Teacher reference number cannot include more than 7 digits"
        end
      end

      context "when no_trn flag is set" do
        before { form.no_trn = true }

        it { is_expected.not_to validate_presence_of(:trn).on(:trn) }
      end

      describe "next_step" do
        subject(:next_step) { form.next_step }

        context "when no_trn flag is set" do
          before { form.complete_step(:trn, no_trn: true) }

          it { is_expected.to be :nino }
        end

        context "when no_trn flag is not set" do
          before { form.complete_step(:trn, trn: "1234567") }

          it { is_expected.to be :dob }
        end
      end

      describe "on completion" do
        let(:dob) { 20.years.ago - rand(1..365).days }

        before { form.dob = dob }

        context "when both trn and date of birth are present" do
          it "attempts to validate the participant" do
            form.complete_step(:trn, trn: Array.new(rand(5..7)) { rand(1..9) }.join)

            expect(ParticipantValidationService).to have_received(:validate).with(
              hash_including(
                date_of_birth: form.dob,
                trn: form.formatted_trn,
              ),
            )
          end
        end

        context "when no_trn flag is set" do
          it "does not attempt to validate the participant" do
            form.complete_step(:trn, no_trn: true)
            expect(ParticipantValidationService).not_to have_received(:validate)
          end
        end

        context "when date of birth is missing" do
          let(:dob) { nil }

          it "does not attempt to validate the participant" do
            form.complete_step(:trn, trn: Array.new(rand(5..7)) { rand(1..9) }.join)
            expect(ParticipantValidationService).not_to have_received(:validate)
          end
        end
      end
    end

    describe "STEP nino" do
      it { is_expected.to validate_presence_of(:nino).on(:nino) }

      describe "next_step" do
        subject(:next_step) { form.next_step }
        before { form.complete_step(:nino, nino: "AB123456C") }

        it { is_expected.to be :dob }
      end

      describe "on completion" do
        let(:dob) { 20.years.ago - rand(1..365).days }

        before { form.dob = dob }

        context "when date of birth is present" do
          it "attempts to validate the participant" do
            form.complete_step(:nino, nino: "AB123456C")

            expect(ParticipantValidationService).to have_received(:validate).with(
              hash_including(
                date_of_birth: form.dob,
                nino: form.nino,
              ),
            )
          end
        end

        context "when date of birth is missing" do
          let(:dob) { nil }

          it "does not attempt to validate the participant" do
            form.complete_step(:nino, nino: "AB123456C")
            expect(ParticipantValidationService).not_to have_received(:validate)
          end
        end
      end
    end

    describe "STEP dob" do
      let(:dob) { 20.years.ago - rand(1..365).days }

      it { is_expected.to validate_presence_of(:dob).on(:dob) }

      describe "next_step" do
        subject(:next_step) { form.next_step }
        before { form.complete_step(:dob, dob:) }

        context "when validation attempt found no matching dqt record" do
          let(:validation_result) { nil }

          it { is_expected.to be :no_match }
        end

        context "when validation attempt found a matching dqt record" do
          let(:validation_result) { { trn: "1234567" } }

          context "resulting in eligible status" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :eligible, participant_profile: }

            it { is_expected.to be :eligible }
          end

          context "requiring further manual checks" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :manual_check, participant_profile: }

            it { is_expected.to be :manual_check }
          end

          context "resulting in eligible status" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :ineligible, participant_profile: }

            it { is_expected.to be :ineligible }
          end
        end
      end

      describe "on completion" do
        it "attempts to validate the participant" do
          form.complete_step(:dob, dob:)

          expect(ParticipantValidationService).to have_received(:validate).with(
            hash_including(
              date_of_birth: form.dob,
            ),
          )
        end
      end
    end

    describe "STEP no_match" do
      describe "next_step" do
        subject(:next_step) { form.next_step }
        before do
          form.completed_steps = completed_steps
          form.complete_step(:no_match)
        end

        context "when nino step has not been completed yet" do
          let(:completed_steps) { described_class.steps.keys.without(:nino).sample(2) }
          it { is_expected.to be :nino }
        end

        context "when nino step has been completed" do
          let(:completed_steps) { %i[nino] }
          it { is_expected.to be :name_changed }
        end

        context "when both nino and name_changed step has been completed" do
          let(:completed_steps) { %i[nino name_changed] }
          it { is_expected.to be :manual_check }
        end
      end

      describe "on completion" do
        context "when both nino and name_changed step has been completed" do
          before { form.completed_steps = %i[nino name_changed] }

          it "stores validation data" do
            form.complete_step(:no_match)

            expect(StoreValidationResult).to have_received(:call).with(
              hash_including(participant_profile:),
            )
          end
        end
      end
    end
  end
end
