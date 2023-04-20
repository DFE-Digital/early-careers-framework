# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::EmailAlreadyTakenStep, type: :model do
  subject(:step) { described_class.new }

  describe "#next_step" do
    it "should return :email" do
      expect(step.next_step).to eql :email
    end
  end
end
