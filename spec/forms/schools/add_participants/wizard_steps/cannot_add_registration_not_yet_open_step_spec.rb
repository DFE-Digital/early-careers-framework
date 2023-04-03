# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CannotAddRegistrationNotYetOpenStep, type: :model do
  subject(:step) { described_class.new }

  describe "#next_step" do
    it "does not have a next step" do
      expect(step.next_step).to eql :none
    end
  end

  describe "#previous_step" do
    it "returns the previous step" do
      expect(step.previous_step).to eql :start_date
    end
  end
end
