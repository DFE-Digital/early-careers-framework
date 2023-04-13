# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::DifferentNameStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name) }
  end

  describe ".permitted_params" do
    it "returns the permitted params for the step" do
      expect(described_class.permitted_params).to eql %i[full_name]
    end
  end

  describe "#next_step" do
    let(:participant_exists?) { false }
    let(:ect_participant?) { false }
    let(:dqt_record_has_different_name?) { false }
    let(:found_participant_in_dqt?) { false }
    let(:sit_mentor?) { false }

    before do
      allow(wizard).to receive(:participant_exists?).and_return(participant_exists?)
      allow(wizard).to receive(:ect_participant?).and_return(ect_participant?)
      allow(wizard).to receive(:dqt_record_has_different_name?).and_return(dqt_record_has_different_name?)
      allow(wizard).to receive(:found_participant_in_dqt?).and_return(found_participant_in_dqt?)
      allow(wizard).to receive(:sit_mentor?).and_return(sit_mentor?)
    end

    context "when the participant already exists" do
      let(:participant_exists?) { true }

      context "when the participant is an ECT" do
        let(:ect_participant?) { true }

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

    context "when the DQT record has a different name" do
      let(:dqt_record_has_different_name?) { true }

      it "returns :known_by_another_name" do
        expect(step.next_step).to eql :known_by_another_name
      end
    end

    context "when a matching DQT is found" do
      let(:found_participant_in_dqt?) { true }

      it "returns :none" do
        expect(step.next_step).to eql :none
      end
    end

    context "when the SIT is adding themself as a mentor" do
      let(:sit_mentor?) { true }

      it "returns :none" do
        expect(step.next_step).to eql :none
      end
    end

    context "when a DQT record cannot be found and the SIT isn't adding themself as a mentor" do
      it "returns :cannot_find_their_details" do
        expect(step.next_step).to eql :cannot_find_their_details
      end
    end
  end

  describe "#previous_step" do
    it "returns :known_by_another_name" do
      expect(step.previous_step).to eql :known_by_another_name
    end
  end

  describe "#journey_complete?" do
    context "when the #next_step returns :none" do
      it "returns true" do
        allow(step).to receive(:next_step).and_return(:none)
        expect(step).to be_journey_complete
      end
    end

    context "when the #next_step does not return :none" do
      it "returns false" do
        allow(step).to receive(:next_step).and_return(:cannot_find_their_details)
        expect(step).not_to be_journey_complete
      end
    end
  end
end
