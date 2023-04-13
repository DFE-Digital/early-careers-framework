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

  describe "#previous_step" do
    context "when the SIT is adding an ECT or mentor" do
      it "returns the start_date step" do
        allow(wizard).to receive(:sit_mentor?).and_return(false)
        expect(step.previous_step).to eql :start_date
      end
    end

    context "when the SIT is adding themselves as a mentor" do
      it "returns the date_of_birth step" do
        allow(wizard).to receive(:sit_mentor?).and_return(true)
        expect(step.previous_step).to eql :date_of_birth
      end
    end
  end
end
