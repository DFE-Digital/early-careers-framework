# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::KnownByAnotherNameStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:known_by_another_name).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[known_by_another_name]
    end
  end

  describe "#before_render" do
    it "resets any response already received (this step can iterate)" do
      expect(wizard).to receive(:reset_known_by_another_name_response).once
      step.before_render
    end
  end

  describe "#next_step" do
    context "when the participant will join the school's programme" do
      it "returns :different_name" do
        step.known_by_another_name = "yes"
        expect(step.next_step).to eql :different_name
      end
    end

    context "when the participant will not join the school's programme" do
      it "returns :cannot_add_mismatch" do
        step.known_by_another_name = "no"
        expect(step.next_step).to eql :cannot_add_mismatch
      end
    end
  end

  describe "#known_by_another_name?" do
    context "when the participant is known by another name" do
      it "returns true" do
        step.known_by_another_name = "yes"
        expect(step).to be_known_by_another_name
      end
    end

    context "when the participant is not known by another name" do
      it "returns false" do
        step.known_by_another_name = nil
        expect(step).not_to be_known_by_another_name

        step.known_by_another_name = "no"
        expect(step).not_to be_known_by_another_name
      end
    end
  end
end
