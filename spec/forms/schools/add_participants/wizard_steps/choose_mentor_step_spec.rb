# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::ChooseMentorStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::AddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    let(:mentors) { create_list(:seed_mentor_participant_profile, 2, :valid) }

    before do
      allow(wizard).to receive(:mentor_options).and_return(mentors)
    end

    it { is_expected.to validate_presence_of(:mentor_id) }
    it { is_expected.to validate_inclusion_of(:mentor_id).in_array(mentors.map(&:id) + %w[later]) }
  end

  describe ".permitted_params" do
    it "returns the mentor_id" do
      expect(described_class.permitted_params).to eql %i[mentor_id]
    end
  end

  describe "#next_step" do
    context "when transferring an ECT" do
      let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }

      before do
        allow(wizard).to receive(:transfer?).and_return(true)
      end

      context "when the ECT is on a different programme" do
        it "should return continue_current_programme" do
          allow(wizard).to receive(:needs_to_confirm_programme?).and_return(true)
          expect(step.next_step).to eql :continue_current_programme
        end
      end

      context "when the ECT is training with the same provider" do
        it "should return check_answers" do
          allow(wizard).to receive(:needs_to_confirm_programme?).and_return(false)
          expect(step.next_step).to eql :check_answers
        end
      end
    end

    context "when adding an ECT" do
      before do
        allow(wizard).to receive(:transfer?).and_return(false)
      end

      context "when the school has an appropriate body set" do
        it "should return confirm_appropriate_body" do
          allow(wizard).to receive(:needs_to_confirm_appropriate_body?).and_return(true)
          expect(step.next_step).to eql :confirm_appropriate_body
        end
      end

      context "when the school does not have an appropriate body set" do
        it "should return check_answers" do
          allow(wizard).to receive(:needs_to_confirm_appropriate_body?).and_return(false)
          expect(step.next_step).to eql :check_answers
        end
      end
    end
  end
end
