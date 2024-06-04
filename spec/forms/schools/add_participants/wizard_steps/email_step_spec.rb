# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::EmailStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::AddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_values("a.sensible@email-address.com", "another@address.co.uk").for(:email) }
    it { is_expected.not_to allow_values("a.bad.email.address.com", "another.uk").for(:email) }
  end

  describe ".permitted_params" do
    it "returns email" do
      expect(described_class.permitted_params).to eql %i[email]
    end
  end

  describe "#next_step" do
    let(:automatically_assign_next_cohort) { false }
    let(:email_taken) { false }
    let(:transfer) { false }
    let(:choose_mentor) { false }
    let(:confirm_programme) { false }
    let(:choose_school_programme) { false }
    let(:ect_participant) { false }
    let(:confirm_start_term) { false }
    let(:confirm_appropriate_body) { false }
    let(:sit_adding_themself_as_mentor) { false }
    let(:adding_yourself_as_ect) { false }
    let(:choose_partnership) { false }

    before do
      allow(wizard).to receive(:automatically_assign_next_cohort?).and_return(automatically_assign_next_cohort)
      allow(wizard).to receive(:email_in_use?).and_return(email_taken)
      allow(wizard).to receive(:transfer?).and_return(transfer)
      allow(wizard).to receive(:needs_to_choose_a_mentor?).and_return(choose_mentor)
      allow(wizard).to receive(:ect_participant?).and_return(ect_participant)
      allow(wizard).to receive(:sit_adding_themself_as_mentor?).and_return(sit_adding_themself_as_mentor)
      allow(wizard).to receive(:adding_yourself_as_ect?).and_return(adding_yourself_as_ect)
    end

    context "when registration is not yet open" do
      let(:automatically_assign_next_cohort) { true }
      let(:registration_open) { false }

      it "returns :cannot_add_registration_not_yet_open" do
        expect(step.next_step).to eql :cannot_add_registration_not_yet_open
      end
    end

    context "when the email is already in use" do
      let(:email_taken) { true }

      it "returns :email_already_taken" do
        expect(step.next_step).to eql :email_already_taken
      end
    end

    context "when participant is a transfer" do
      let(:wizard) { instance_double(Schools::AddParticipants::TransferWizard) }
      let(:transfer) { true }

      before do
        allow(wizard).to receive(:needs_to_confirm_programme?).and_return(confirm_programme)
        allow(wizard).to receive(:needs_to_choose_school_programme?).and_return(choose_school_programme)
      end

      it "returns :cannot_add_manual_transfer" do
        expect(step.next_step).to eql :cannot_add_manual_transfer
      end

      context "when a mentor can be chosen" do
        let(:choose_mentor) { true }

        it "returns :choose_mentor" do
          expect(step.next_step).to eql :choose_mentor
        end
      end

      context "when the programme needs to be confirmed" do
        let(:confirm_programme) { true }

        it "returns :continue_current_programme" do
          expect(step.next_step).to eql :continue_current_programme
        end
      end

      context "when a school programme needs to be chosen" do
        let(:choose_school_programme) { true }

        it "returns :join_school_programme" do
          expect(step.next_step).to eql :join_school_programme
        end
      end
    end

    context "when the participant is an ECT" do
      let(:ect_participant) { true }

      before do
        allow(wizard).to receive(:needs_to_confirm_appropriate_body?).and_return(confirm_appropriate_body)
        allow(wizard).to receive(:needs_to_choose_partnership?).and_return(choose_partnership)
      end

      it "returns :check_answers" do
        expect(step.next_step).to eql :check_answers
      end

      context "when the SIT needs to confirm the start term" do
        let(:confirm_start_term) { true }

        it "returns :start_term" do
          expect(step.next_step).to eql :start_term
        end
      end

      context "when a mentor can be chosen" do
        let(:choose_mentor) { true }

        it "returns :choose_mentor" do
          expect(step.next_step).to eql :choose_mentor
        end
      end

      context "when an appropriate body needs to be confirmed" do
        let(:confirm_appropriate_body) { true }

        it "returns :confirm_appropriate_body" do
          expect(step.next_step).to eql :confirm_appropriate_body
        end
      end

      context "when SIT is adding themself as mentor" do
        let(:sit_adding_themself_as_mentor) { true }

        it "returns :yourself" do
          expect(step.next_step).to eql :yourself
        end
      end

      context "when SIT is adding themself as ECT" do
        let(:adding_yourself_as_ect) { true }

        it "returns :cannot_add_yourself_as_ect" do
          expect(step.next_step).to eql :cannot_add_yourself_as_ect
        end
      end

      context "when a partnership needs to be chosen" do
        let(:choose_partnership) { true }

        it "returns :choose_mentor" do
          expect(step.next_step).to eql :choose_partnership
        end
      end
    end
  end
end
