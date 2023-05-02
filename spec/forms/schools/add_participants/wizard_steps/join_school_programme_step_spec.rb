# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::JoinSchoolProgrammeStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:join_school_programme).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[join_school_programme]
    end
  end

  describe "#next_step" do
    context "when the participant will join the school's programme" do
      it "returns :check_answers" do
        step.join_school_programme = "yes"
        expect(step.next_step).to eql :check_answers
      end
    end

    context "when the participant will not join the school's programme" do
      it "returns :cannot_add_manual_transfer" do
        step.join_school_programme = "no"
        expect(step.next_step).to eql :cannot_add_manual_transfer
      end
    end
  end

  describe "#join_school_programme?" do
    context "when the participant will join the school's programme" do
      it "returns true" do
        step.join_school_programme = "yes"
        expect(step).to be_join_school_programme
      end
    end

    context "when the participant will not join the school's programme" do
      it "returns false" do
        step.join_school_programme = nil
        expect(step).not_to be_join_school_programme

        step.join_school_programme = "no"
        expect(step).not_to be_join_school_programme
      end
    end
  end
end
