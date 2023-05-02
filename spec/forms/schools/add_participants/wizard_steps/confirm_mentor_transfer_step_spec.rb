# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ConfirmMentorTransferStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:transfer_confirmed).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns transfer_confirmed" do
      expect(described_class.permitted_params).to eql %i[transfer_confirmed]
    end
  end

  describe "#next_step" do
    context "when transfer is confirmed" do
      before do
        step.transfer_confirmed = "yes"
      end

      context "when a training choice has been made" do
        it "returns :none" do
          allow(wizard).to receive(:need_training_setup?).and_return(false)
          expect(step.next_step).to eql :none
        end
      end

      context "when training choice has not been made" do
        it "returns :need_training_setup" do
          allow(wizard).to receive(:need_training_setup?).and_return(true)
          expect(step.next_step).to eql :need_training_setup
        end
      end
    end

    context "when the transfer is not confirmed" do
      before do
        step.transfer_confirmed = "no"
      end

      it "returns :cannot_add_mentor_at_multiple_schools" do
        expect(step.next_step).to eql :cannot_add_mentor_at_multiple_schools
      end
    end
  end

  describe "#journey_complete?" do
    context "when the transfer isn't confirmed" do
      it "returns false" do
        step.transfer_confirmed = "no"
        allow(wizard).to receive(:need_training_setup?).and_return(false)
        expect(step).not_to be_journey_complete
      end
    end

    context "when there isn't a training programme" do
      it "returns false" do
        step.transfer_confirmed = "yes"
        allow(wizard).to receive(:need_training_setup?).and_return(true)
        expect(step).not_to be_journey_complete
      end
    end

    context "when the transfer is confirmed and there is a training programme in place" do
      before do
        step.transfer_confirmed = "yes"
        allow(wizard).to receive(:need_training_setup?).and_return(false)
      end

      it "returns true" do
        expect(step).to be_journey_complete
      end
    end
  end
end
