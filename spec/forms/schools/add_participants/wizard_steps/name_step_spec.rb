# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::NameStep, type: :model do
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
    it "returns :trn" do
      expect(step.next_step).to eql :trn
    end
  end
end
