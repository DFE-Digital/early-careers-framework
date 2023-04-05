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

  describe "#previous_step" do
    context "when participant is an ECT" do
      let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }

      before do
        allow(wizard).to receive(:ect_participant?).and_return(true)
      end

      context "when there are mentors available to assign" do
        let(:mentors) { create_list(:seed_mentor_participant_profile, 2, :valid) }

        it "returns :choose_mentor" do
          allow(wizard).to receive(:mentor_options).and_return(mentors)
          expect(step.previous_step).to eql :choose_mentor
        end
      end

      context "when there are no mentors available" do
        let(:mentors) { [] }

        it "returns :start_date" do
          allow(wizard).to receive(:mentor_options).and_return(mentors)
          expect(step.previous_step).to eql :start_date
        end
      end
    end
    context "when participant is a mentor" do
      it "returns :email" do
        allow(wizard).to receive(:ect_participant?).and_return(false)
        expect(step.previous_step).to eql :email
      end
    end
  end
end
