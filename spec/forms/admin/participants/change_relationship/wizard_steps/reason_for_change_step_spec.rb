# frozen_string_literal: true

RSpec.describe Admin::Participants::ChangeRelationship::WizardSteps::ReasonForChangeStep, type: :model do
  let(:wizard) { instance_double(Admin::Participants::ChangeRelationship::ChangeRelationshipWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:reason_for_change).in_array(described_class::VALID_OPTIONS) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[reason_for_change]
    end
  end

  describe "#expected" do
    it "returns true" do
      expect(step).to be_expected
    end
  end

  describe "#next_step" do
    let(:can_be_changed) { true }

    before do
      allow(wizard).to receive(:programme_can_be_changed?).and_return(can_be_changed)
    end

    context "when the reason for change is to fix a mistake" do
      before do
        step.reason_for_change = "wrong_programme"
      end

      it "returns :change_training_programme" do
        expect(step.next_step).to eql :change_training_programme
      end

      context "when the programme cannot be changed" do
        let(:can_be_changed) { false }

        it "returns :cannot_change_programme" do
          expect(step.next_step).to eql :cannot_change_programme
        end
      end
    end

    context "when the reason is a change of circumstance" do
      before do
        step.reason_for_change = "change_of_circumstances"
      end

      it "returns :change_training_programme" do
        expect(step.next_step).to eql :change_training_programme
      end
    end
  end

  describe "#options" do
    it "returns the permitted options" do
      allow(wizard).to receive(:i18n_text).and_return("Test").twice
      expect(step.options.map(&:id)).to match_array described_class::VALID_OPTIONS
    end
  end
end
