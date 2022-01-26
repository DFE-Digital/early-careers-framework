# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ParticipantValidationForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }

  let(:participant_profile) { create :ect_participant_profile }
  let(:validation_result) { [nil, spy].sample }
  let(:eligibility_record) { build :ecf_participant_eligibility, participant_profile: participant_profile }

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return(validation_result)
    allow(StoreValidationResult).to receive(:call).and_return(eligibility_record)
  end

  describe "steps" do
    describe "STEP trn" do
      context "when no_trn flag is not set" do
        it { is_expected.to validate_presence_of(:trn).on(:trn) }
        it { is_expected.to validate_length_of(:trn).is_at_least(5).is_at_most(7) }
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
                trn: form.trn,
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
        before { form.complete_step(:dob, dob: dob) }

        context "when validation attempt found no matching dqt record" do
          let(:validation_result) { nil }

          it { is_expected.to be :no_match }
        end

        context "when validation attempt found a matching dqt record" do
          let(:validation_result) { { trn: "1234567" } }

          context "resulting in eligible status" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :eligible, participant_profile: participant_profile }

            it { is_expected.to be :eligible }
          end

          context "requiring further manual checks" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :manual_check, participant_profile: participant_profile }

            it { is_expected.to be :manual_check }
          end

          context "resulting in eligible status" do
            let(:eligibility_record) { create :ecf_participant_eligibility, :ineligible, participant_profile: participant_profile }

            it { is_expected.to be :ineligible }
          end
        end
      end

      describe "on completion" do
        it "attempts to validate the participant" do
          form.complete_step(:dob, dob: dob)

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
              hash_including(participant_profile: participant_profile),
            )
          end
        end
      end
    end
  end
end
