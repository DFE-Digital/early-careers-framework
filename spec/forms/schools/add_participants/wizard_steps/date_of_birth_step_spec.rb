# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::DateOfBirthStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:date_of_birth) }

    it "validates that :date_of_birth is later than 1900" do
      step.date_of_birth = { 1 => 1899, 2 => 1, 3 => 16 }
      expect(step).not_to be_valid
      expect(step.errors[:date_of_birth]).to be_present

      step.date_of_birth = { 1 => 1999, 2 => 1, 3 => 16 }
      expect(step).to be_valid
    end

    it "validates that :date_of_birth is earlier than 18 years ago" do
      recent = 17.years.ago
      step.date_of_birth = { 1 => recent.year, 2 => recent.month, 3 => recent.day }
      expect(step).not_to be_valid
      expect(step.errors[:date_of_birth]).to be_present

      recent = 19.years.ago
      step.date_of_birth = { 1 => recent.year, 2 => recent.month, 3 => recent.day }
      expect(step).to be_valid
    end
  end

  describe ".permitted_params" do
    it "returns date_of_birth" do
      expect(described_class.permitted_params).to eql %i[date_of_birth]
    end
  end

  describe "#next_step" do
    context "when participant already exists" do
      before do
        allow(wizard).to receive(:participant_exists?).and_return(true)
      end

      context "when the participant is a different type" do
        before do
          allow(wizard).to receive(:existing_participant_is_a_different_type?).and_return(true)
        end

        context "when the existing participant is a mentor and the SIT tries to add an ECT" do
          it "returns :cannot_add_ect_because_already_a_mentor" do
            allow(wizard).to receive(:ect_participant?).and_return(true)
            expect(step.next_step).to eql :cannot_add_ect_because_already_a_mentor
          end
        end

        context "when the existing participant is an ECT and the SIT tries to add a mentor" do
          it "returns :cannot_add_mentor_because_already_an_ect" do
            allow(wizard).to receive(:ect_participant?).and_return(false)
            expect(step.next_step).to eql :cannot_add_mentor_because_already_an_ect
          end
        end
      end

      context "when the participant is the same type" do
        before do
          allow(wizard).to receive(:existing_participant_is_a_different_type?).and_return(false)
        end

        context "when the participant is already enrolled at the school" do
          it "returns :cannot_add_already_enrolled_at_school" do
            allow(wizard).to receive(:already_enrolled_at_school?).and_return(true)
            expect(step.next_step).to eql :cannot_add_already_enrolled_at_school
          end
        end

        context "when the participant is at a different school" do
          before do
            allow(wizard).to receive(:already_enrolled_at_school?).and_return(false)
          end

          context "when the participant is an ECT" do
            it "returns :confirm_transfer" do
              allow(wizard).to receive(:ect_participant?).and_return(true)
              expect(step.next_step).to eql :confirm_transfer
            end
          end

          context "when the participant is a mentor" do
            it "returns :confirm_mentor_transfer" do
              allow(wizard).to receive(:ect_participant?).and_return(false)
              expect(step.next_step).to eql :confirm_mentor_transfer
            end
          end
        end
      end
    end

    context "when participant does not exist" do
      before do
        allow(wizard).to receive(:participant_exists?).and_return(false)
      end

      context "when the DQT has a record in a different name" do
        before do
          allow(wizard).to receive(:dqt_record_has_different_name?).and_return(true)
        end

        it "returns :known_by_another_name" do
          expect(step.next_step).to eql :known_by_another_name
        end
      end

      context "when a matching DQT record is found with the correct name" do
        before do
          allow(wizard).to receive(:dqt_record_has_different_name?).and_return(false)
          allow(wizard).to receive(:found_participant_in_dqt?).and_return(true)
          allow(wizard).to receive(:sit_mentor?).and_return(false)
        end

        it "returns :none" do
          expect(step.next_step).to eql :none
        end
      end

      context "when no matching DQT record is found" do
        before do
          allow(wizard).to receive(:dqt_record_has_different_name?).and_return(false)
          allow(wizard).to receive(:found_participant_in_dqt?).and_return(false)
        end

        it "returns :cannot_find_their_details" do
          allow(wizard).to receive(:sit_mentor?).and_return(false)
          expect(step.next_step).to eql :cannot_find_their_details
        end

        context "when adding a SIT mentor" do
          it "returns :none" do
            allow(wizard).to receive(:sit_mentor?).and_return(true)
            expect(step.next_step).to eql :none
          end
        end
      end
    end
  end

  describe "#previous_step" do
    it "returns :trn" do
      expect(step.previous_step).to eql :trn
    end
  end

  describe "#journey_complete" do
    context "when adding a new participant and a matching DQT record is found" do
      it "returns true" do
        allow(wizard).to receive(:participant_exists?).and_return(false)
        allow(wizard).to receive(:dqt_record_has_different_name?).and_return(false)
        allow(wizard).to receive(:found_participant_in_dqt?).and_return(true)
        expect(step).to be_journey_complete
      end
    end

    context "when adding a new SIT mentor" do
      it "returns true" do
        allow(wizard).to receive(:participant_exists?).and_return(false)
        allow(wizard).to receive(:dqt_record_has_different_name?).and_return(false)
        allow(wizard).to receive(:found_participant_in_dqt?).and_return(false)
        allow(wizard).to receive(:sit_mentor?).and_return(true)
        expect(step).to be_journey_complete
      end
    end

    context "when a participant is at another school" do
      it "returns false" do
        allow(wizard).to receive(:participant_exists?).and_return(true)
        allow(wizard).to receive(:existing_participant_is_a_different_type?).and_return(false)
        allow(wizard).to receive(:already_enrolled_at_school?).and_return(false)
        allow(wizard).to receive(:ect_participant?).and_return(true)
        expect(step).not_to be_journey_complete
      end
    end
  end
end
