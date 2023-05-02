# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CompleteStep, type: :model do
  subject(:step) { described_class.new }

  describe "#next_step" do
    it "should be none" do
      expect(step.next_step).to eql :none
    end
  end
end
