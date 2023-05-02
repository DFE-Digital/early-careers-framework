# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ConfirmAppropriateBodyStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::AddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe ".permitted_params" do
    it "returns appropriate_body_confirmed" do
      expect(described_class.permitted_params).to eql %i[appropriate_body_confirmed]
    end
  end

  describe "#before_render" do
    it "resets the appropriate_body_confirmed flag" do
      expect(wizard).to receive(:appropriate_body_confirmed=).with(false)
      step.before_render
    end
  end

  describe "#next_step" do
    it "should return check_answers" do
      expect(step.next_step).to eql :check_answers
    end
  end
end
