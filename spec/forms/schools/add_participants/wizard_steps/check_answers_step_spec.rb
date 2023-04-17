# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::CheckAnswersStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::AddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "#before_render" do
    it "should set the return point for changing details" do
      expect(wizard).to receive(:set_return_point).with(:check_answers).once
      step.before_render
    end
  end

  describe "#next_step" do
    it "should be complete" do
      expect(step.next_step).to eql :complete
    end
  end
end
