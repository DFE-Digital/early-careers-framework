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
    let(:participant_exists) { false }
    let(:ect) { false }
    let(:different_type) { false }
    let(:already_at_school) { false }
    let(:different_name) { false }
    let(:sit_mentor) { false }
    let(:found_in_dqt) { false }
    let(:registration_open) { false }
    let(:need_setup) { false }
    let(:confirm_start_term) { false }

    before do
      allow(wizard).to receive(:participant_exists?).and_return(participant_exists)
      allow(wizard).to receive(:ect_participant?).and_return(ect)
      allow(wizard).to receive(:existing_participant_is_a_different_type?).and_return(different_type)
      allow(wizard).to receive(:already_enrolled_at_school?).and_return(already_at_school)
      allow(wizard).to receive(:dqt_record_has_different_name?).and_return(different_name)
      allow(wizard).to receive(:sit_mentor?).and_return(sit_mentor)
      allow(wizard).to receive(:found_participant_in_dqt?).and_return(found_in_dqt)
      allow(wizard).to receive(:registration_open_for_participant_cohort?).and_return(registration_open)
      allow(wizard).to receive(:need_training_setup?).and_return(need_setup)
      allow(wizard).to receive(:needs_to_confirm_start_term?).and_return(confirm_start_term)
    end

    context "when participant already exists" do
      let(:participant_exists) { true }

      context "when the participant is a different type" do
        let(:different_type) { true }

        context "when the existing participant is a mentor and the SIT tries to add an ECT" do
          let(:ect) { true }

          it "returns :cannot_add_ect_because_already_a_mentor" do
            expect(step.next_step).to eql :cannot_add_ect_because_already_a_mentor
          end
        end

        context "when the existing participant is an ECT and the SIT tries to add a mentor" do
          it "returns :cannot_add_mentor_because_already_an_ect" do
            expect(step.next_step).to eql :cannot_add_mentor_because_already_an_ect
          end
        end
      end

      context "when the participant is the same type" do
        context "when the participant is already enrolled at the school" do
          let(:already_at_school) { true }

          it "returns :cannot_add_already_enrolled_at_school" do
            expect(step.next_step).to eql :cannot_add_already_enrolled_at_school
          end
        end

        context "when the participant is at a different school" do
          context "when the participant is an ECT" do
            let(:ect) { true }

            it "returns :confirm_transfer" do
              expect(step.next_step).to eql :confirm_transfer
            end
          end

          context "when the participant is a mentor" do
            it "returns :confirm_mentor_transfer" do
              expect(step.next_step).to eql :confirm_mentor_transfer
            end
          end
        end
      end
    end

    context "when the DQT has a record in a different name" do
      let(:different_name) { true }

      it "returns :known_by_another_name" do
        expect(step.next_step).to eql :known_by_another_name
      end
    end

    context "when a matching DQT record is found with the correct name" do
      let(:found_in_dqt) { true }

      context "when registration is available" do
        let(:registration_open) { true }

        it "returns :none" do
          expect(step.next_step).to eql :none
        end

        context "when the participant will be asked the start_term question" do
          let(:confirm_start_term) { true }

          it "returns :none" do
            expect(step.next_step).to eql :none
          end
        end

        context "when the cohort needs to be set up" do
          let(:need_setup) { true }

          it "returns :need_training_setup" do
            expect(step.next_step).to eql :need_training_setup
          end
        end
      end

      context "when registration is not open" do
        it "returns :cannot_add_registration_not_yet_open" do
          expect(step.next_step).to eql :cannot_add_registration_not_yet_open
        end
      end
    end

    context "when no matching DQT record is found" do
      it "returns :cannot_find_their_details" do
        expect(step.next_step).to eql :cannot_find_their_details
      end

      context "when adding a SIT mentor" do
        let(:sit_mentor) { true }
        # SIT mentor always added to current cohort
        let(:registration_open) { true }

        it "returns :none" do
          expect(step.next_step).to eql :none
        end

        context "when the cohort needs to be set up" do
          let(:need_setup) { true }

          it "returns :need_training_setup" do
            expect(step.next_step).to eql :need_training_setup
          end
        end
      end
    end
  end

  describe "#journey_complete" do
    context "when #next_step returns :none" do
      it "returns true" do
        allow(step).to receive(:next_step).and_return(:none)
        expect(step).to be_journey_complete
      end
    end

    context "when #next_step does not return :none" do
      it "returns false" do
        allow(step).to receive(:next_step).and_return(:need_training_setup)
        expect(step).not_to be_journey_complete
      end
    end
  end
end
