# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CannotAddStep, type: :model do
  subject(:step) { described_class.new }

  describe "#next_step" do
    it "does not have a next step" do
      expect(step.next_step).to eql :none
    end
  end
end
