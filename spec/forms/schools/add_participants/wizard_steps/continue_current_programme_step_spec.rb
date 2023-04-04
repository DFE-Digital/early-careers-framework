# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ContinueCurrentProgrammeStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:continue_current_programme).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns continue_current_programme" do
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

  describe "#previous_step" do
    context "when the participant is an ECT" do
      before do
        allow(wizard).to receive(:ect_participant?).and_return(true)
      end

      context "when there are mentors available" do
        let(:mentors) { create_list(:seed_mentor_participant_profile, 2, :valid) }

        it "returns :choose_mentor" do
          allow(wizard).to receive(:mentor_options).and_return(mentors)
          expect(step.previous_step).to eql :choose_mentor
        end
      end

      context "when there are no mentors available" do
        it "returns :email" do
          allow(wizard).to receive(:mentor_options).and_return([])
          expect(step.previous_step).to eql :email
        end
      end
    end

    context "when the participant is a mentor" do
      it "returns :email" do
        allow(wizard).to receive(:ect_participant?).and_return(false)
        expect(step.previous_step).to eql :email
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
