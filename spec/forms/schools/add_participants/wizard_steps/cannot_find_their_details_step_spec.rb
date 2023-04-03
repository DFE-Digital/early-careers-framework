# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CannotFindTheirDetailsStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "#before_render" do
    it "should set the return point for changing details" do
      expect(wizard).to receive(:set_return_point).with(:cannot_find_their_details).once
      step.before_render
    end
  end

  describe "#next_step" do
    it "should go to the nino question next" do
      expect(step.next_step).to eql :nino
    end
  end

  describe "#previous_step" do
    it "returns the previous step" do
      expect(step.previous_step).to eql :date_of_birth
    end
  end
end
