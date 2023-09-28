# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CannotAddYourselfAsECTStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::AddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:participant_type).in_array(%w[mentor return]) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[participant_type]
    end
  end

  describe "#next_step" do
    context "when the SIT chooses to add themselves as a mentor" do
      it "returns :yourself" do
        step.participant_type = "mentor"
        expect(step.next_step).to eql :yourself
      end
    end

    context "when the SIT chooses to cancel" do
      it "returns :abort" do
        step.participant_type = "return"
        expect(step.next_step).to eql :abort
      end
    end
  end
end
