# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ContinueCurrentProgrammeStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:continue_current_programme).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns the permitted params for the step" do
      expect(described_class.permitted_params).to eql %i[continue_current_programme]
    end
  end

  describe "#next_step" do
    context "when continuing the current programme" do
      it "returns :check_answers" do
        step.continue_current_programme = "yes"
        expect(step.next_step).to eql :check_answers
      end
    end

    context "when not continuing the current programme" do
      it "returns :join_school_programme" do
        step.continue_current_programme = "no"
        expect(step.next_step).to eql :join_school_programme
      end
    end
  end

  describe "#revisit_next_step?" do
    context "when continue current programme is chosen" do
      it "returns false" do
        step.continue_current_programme = "yes"
        expect(step).not_to be_revisit_next_step
      end
    end

    context "when not continuing the current programme" do
      it "returns true" do
        step.continue_current_programme = "no"
        expect(step).to be_revisit_next_step
      end
    end
  end
end
