# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::ParticipantValidationForm, type: :model do
  subject(:form) { described_class.new(participant_profile_id: participant_profile.id) }

  let(:participant_profile) { create :participant_profile, :ecf }
  let(:validation_result) { [nil, spy].sample }
  let(:eligibility_record) { build :ecf_participant_eligibility }

  before do
    allow(ParticipantValidationService).to receive(:validate).and_return(validation_result)
    allow(StoreValidationResult).to receive(:call).and_return(eligibility_record)
  end

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

  # describe "do_you_want_to_add_mentor_information validations" do
  #   context "when a valid choice is made" do
  #     it "returns true" do
  #       form.do_you_want_to_add_mentor_information_choice = form.add_mentor_information_choices.map(&:id).sample
  #       expect(form.valid?(:do_you_want_to_add_mentor_information)).to be true
  #       expect(form.errors).to be_empty
  #     end
  #   end
  #
  #   context "when no choice has been made" do
  #     it "returns false" do
  #       expect(form.valid?(:do_you_want_to_add_mentor_information)).to be false
  #       expect(form.errors).to include :do_you_want_to_add_mentor_information_choice
  #     end
  #   end
  #
  #   context "when an invalid choice has been made" do
  #     it "returns false" do
  #       form.do_you_want_to_add_mentor_information_choice = :banana
  #       expect(form.valid?(:do_you_want_to_add_mentor_information)).to be false
  #       expect(form.errors).to include :do_you_want_to_add_mentor_information_choice
  #     end
  #   end
  # end
  #
  # describe "what_is_your_trn validations" do
  #   context "when trn is not supplied" do
  #     it "returns false" do
  #       form.trn = nil
  #       expect(form.valid?(:what_is_your_trn)).to be false
  #       expect(form.errors).to include :trn
  #     end
  #   end
  #
  #   context "when trn has leading/trailing whiitespace" do
  #     it "strips whitespace and validates" do
  #       form.trn = "   1234567  \t\n"
  #       expect(form.valid?(:what_is_your_trn)).to be true
  #       expect(form.trn).to eq "1234567"
  #     end
  #   end
  #
  #   context "when trn has contains RP and slashes" do
  #     it "strips invalid characters and validates" do
  #       form.trn = " RP12/345 67  \t\n"
  #       expect(form.valid?(:what_is_your_trn)).to be true
  #       expect(form.trn).to eq "1234567"
  #     end
  #   end
  # end
  #
  # describe "teacher_details validations" do
  #   let(:teacher_details) { { trn: "1234567", name: "Wilma Flintstone", date_of_birth: { 3 => 17, 2 => 4, 1 => 1996 }, national_insurance_number: "AB123456C" } }
  #   subject(:form) { described_class.new(teacher_details) }
  #
  #   context "when all fields are valid" do
  #     it "returns true" do
  #       expect(form.valid?(:tell_us_your_details)).to be true
  #     end
  #   end
  #
  #   context "when date_of_birth is not supplied" do
  #     it "returns false" do
  #       form.date_of_birth = nil
  #       expect(form.valid?(:tell_us_your_details)).to be false
  #       expect(form.errors).to include :date_of_birth
  #     end
  #   end
  #
  #   context "when date_of_birth is an invalid date" do
  #     it "returns false" do
  #       form.date_of_birth = { 3 => 31, 2 => 9, 1 => 1988 }
  #       expect(form.valid?(:tell_us_your_details)).to be false
  #       expect(form.errors).to include :date_of_birth
  #     end
  #   end
  #
  #   context "when date_of_birth year is not 4 digits" do
  #     it "returns false" do
  #       form.date_of_birth = { 3 => 1, 2 => 1, 1 => 1 }
  #       expect(form.valid?(:tell_us_your_details)).to be false
  #       expect(form.errors).to include :date_of_birth
  #       expect(form.errors[:date_of_birth]).to include "The year must be 4 digits long. For example, 1990"
  #     end
  #   end
  #
  #   context "when national_insurance_number is not supplied" do
  #     it "returns true" do
  #       form.national_insurance_number = nil
  #       expect(form.valid?(:tell_us_your_details)).to be true
  #       expect(form.errors).to be_empty
  #     end
  #   end
  #
  #   context "when national_insurance_number is in an incorrect format" do
  #     it "returns false" do
  #       form.national_insurance_number = "A 12 VV"
  #       expect(form.valid?(:tell_us_your_details)).to be false
  #       expect(form.errors).to include :national_insurance_number
  #     end
  #   end
  #
  #   context "when national_insurance_number has leading/trailing whiitespace" do
  #     it "strips whitespace and validates" do
  #       form.national_insurance_number = "   AB123456C  \t\n"
  #       expect(form.valid?(:tell_us_your_details)).to be true
  #     end
  #   end
  # end
  #
  # describe "#attributes" do
  #   it "returns a hash of the attribute data" do
  #     values = {
  #       step: :my_step,
  #       do_you_want_to_add_mentor_information_choice: form.add_mentor_information_choices.map(&:id).sample,
  #       trn: "1234567",
  #       name: "Ted Smith",
  #       date_of_birth: form.date_of_birth,
  #       national_insurance_number: "AB123456C",
  #       validation_attempts: 1,
  #     }
  #     form = described_class.new(values)
  #     expect(form.attributes).to match(values)
  #   end
  #
  #   context "when participant details have extraneous whitespace" do
  #     it "squishes the whitespace" do
  #       values = {
  #         trn: "   1231222  \t",
  #         name: "    Shiela\n\t Smith    \n",
  #         national_insurance_number: "    AW  23  44 44  A\t\n ",
  #       }
  #       form = described_class.new(values)
  #       attributes = form.attributes
  #       expect(attributes[:trn]).to eq "1231222"
  #       expect(attributes[:name]).to eq "Shiela Smith"
  #       expect(attributes[:national_insurance_number]).to eq "AW234444A"
  #     end
  #   end
  # end
  #
  # describe "#pretty_date_of_birth" do
  #   it "formats the date of birth correctly" do
  #     form.date_of_birth = { 3 => 22, 2 => 3, 1 => 1989 }
  #     expect(form.pretty_date_of_birth).to eq "22 March 1989"
  #   end
  # end
end
