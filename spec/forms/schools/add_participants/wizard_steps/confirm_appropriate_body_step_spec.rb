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
    context "when a partnership needs to be chosen" do
      before do
        allow(wizard).to receive(:needs_to_choose_partnership?).and_return(true)
      end

      it "returns choose_partnership" do
        expect(step.next_step).to eql :choose_partnership
      end
    end

    context "when a partnership needs not to be chosen" do
      before do
        allow(wizard).to receive(:needs_to_choose_partnership?).and_return(false)
      end

      it "returns check_answers" do
        expect(step.next_step).to eql :check_answers
      end
    end
  end
end
