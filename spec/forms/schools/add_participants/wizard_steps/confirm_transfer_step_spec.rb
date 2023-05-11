# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ConfirmTransferStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:transfer_confirmed).in_array(%w[yes]) }
  end

  describe ".permitted_params" do
    it "returns transfer_confirmed" do
      expect(described_class.permitted_params).to eql %i[transfer_confirmed]
    end
  end

  describe "#next_step" do
    context "when no training choice has been made" do
      it "returns :need_training_setup" do
        allow(wizard).to receive(:destination_school_cohort).and_return(nil)
        expect(step.next_step).to eql :need_training_setup
      end
    end

    context "when a FIP training choice has been made" do
      it "returns :none" do
        allow(wizard).to receive(:destination_school_cohort).and_return(true)
        allow(wizard).to receive(:fip_destination_school_cohort?).and_return(true)
        expect(step.next_step).to eql :none
      end
    end

    context "when a FIP training choice has not been made" do
      it "returns :cannot_transfer_no_fip" do
        allow(wizard).to receive(:destination_school_cohort).and_return(true)
        allow(wizard).to receive(:fip_destination_school_cohort?).and_return(false)
        expect(step.next_step).to eql :cannot_transfer_no_fip
      end
    end
  end

  describe "#journey_complete?" do
    context "when there isn't a training programme" do
      it "returns false" do
        step.transfer_confirmed = "yes"
        allow(wizard).to receive(:destination_school_cohort)
        expect(step).not_to be_journey_complete
      end
    end

    context "when the training programme is not FIP" do
      it "returns false" do
        step.transfer_confirmed = "yes"
        allow(wizard).to receive(:destination_school_cohort).and_return(true)
        allow(wizard).to receive(:fip_destination_school_cohort?).and_return(false)
        expect(step).not_to be_journey_complete
      end
    end

    context "when the transfer is confirmed and there is a FIP training programme in place" do
      before do
        step.transfer_confirmed = "yes"
        allow(wizard).to receive(:destination_school_cohort).and_return(true)
        allow(wizard).to receive(:fip_destination_school_cohort?).and_return(true)
      end

      it "returns true" do
        expect(step).to be_journey_complete
      end
    end
  end
end
