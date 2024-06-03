# frozen_string_literal: true

RSpec.describe Schools::AddParticipants::WizardSteps::NinoStep, type: :model do
  let(:wizard) { instance_double(Schools::AddParticipants::WhoToAddWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to allow_values("AB123456C", "BC123456A").for(:nino) }
    it { is_expected.not_to allow_values(nil, "QQ123456A", "banana").for(:nino) }
  end

  describe ".permitted_params" do
    it "returns the permitted parameters" do
      expect(described_class.permitted_params).to eql %i[nino]
    end
  end

  describe "#next_step" do
    let(:participant_exists) { false }
    let(:different_participant_type) { false }
    let(:ect_participant) { false }
    let(:mentor_participant) { false }
    let(:already_enrolled_at_school_and_training) { false }
    let(:already_enrolled_at_school_but_leaving) { false }
    let(:already_enrolled_at_school_but_withdrawn) { false }
    let(:already_enrolled_at_school_but_deferred) { false }
    let(:already_at_school_and_completed) { false }
    let(:different_name) { false }
    let(:found_dqt_record) { false }
    let(:sit_mentor) { false }
    let(:registration_open) { false }
    let(:need_setup) { false }
    let(:automatically_assign_next_cohort) { false }
    let(:participant_withdrawn) { false }

    before do
      allow(wizard).to receive(:participant_exists?).and_return(participant_exists)
      allow(wizard).to receive(:existing_participant_is_a_different_type?).and_return(different_participant_type)
      allow(wizard).to receive(:ect_participant?).and_return(ect_participant)
      allow(wizard).to receive(:mentor_participant?).and_return(mentor_participant)
      allow(wizard).to receive(:already_enrolled_at_school_and_training?).and_return(already_enrolled_at_school_and_training)
      allow(wizard).to receive(:already_enrolled_at_school_and_completed?).and_return(already_at_school_and_completed)
      allow(wizard).to receive(:already_enrolled_at_school_but_leaving?).and_return(already_enrolled_at_school_but_leaving)
      allow(wizard).to receive(:already_enrolled_at_school_but_withdrawn?).and_return(already_enrolled_at_school_but_withdrawn)
      allow(wizard).to receive(:already_enrolled_at_school_but_deferred?).and_return(already_enrolled_at_school_but_deferred)
      allow(wizard).to receive(:dqt_record_has_different_name?).and_return(different_name)
      allow(wizard).to receive(:found_participant_in_dqt?).and_return(found_dqt_record)
      allow(wizard).to receive(:sit_mentor?).and_return(sit_mentor)
      allow(wizard).to receive(:registration_open_for_participant_cohort?).and_return(registration_open)
      allow(wizard).to receive(:need_training_setup?).and_return(need_setup)
      allow(wizard).to receive(:automatically_assign_next_cohort?).and_return(automatically_assign_next_cohort)
      allow(wizard).to receive(:participant_withdrawn?).and_return(participant_withdrawn)
      allow(wizard).to receive(:set_ect_mentor).and_return(nil)
    end

    shared_examples "cohort and registration checks" do
      context "when registration is available" do
        let(:registration_open) { true }

        it "returns :none" do
          expect(step.next_step).to eql :none
        end

        context "when the participant will be automatically assigned to next cohort" do
          let(:automatically_assign_to_next_cohort) { true }

          it "returns :none" do
            expect(step.next_step).to eql :none
          end
        end

        context "when the cohort needs to be set up" do
          let(:need_setup) { true }

          it "returns :need_training_setup" do
            expect(step.next_step).to eql :need_training_setup
          end
        end
      end

      context "when registration is not open" do
        it "returns :cannot_add_registration_not_yet_open" do
          expect(step.next_step).to eql :cannot_add_registration_not_yet_open
        end
      end
    end

    context "when the participant exists in the service" do
      let(:participant_exists) { true }

      context "when the existing participant is a different type" do
        let(:different_participant_type) { true }

        context "when the new participant is an ECT" do
          let(:ect_participant) { true }

          it "returns :cannot_add_ect_because_already_a_mentor" do
            expect(step.next_step).to eql :cannot_add_ect_because_already_a_mentor
          end
        end

        context "when the new participant is a mentor" do
          let(:mentor_participant) { true }

          context "when the ECT is already enrolled at the school" do
            let(:already_enrolled_at_school_and_training) { true }

            before do
              allow(wizard).to receive(:set_ect_mentor)
            end

            include_examples "cohort and registration checks"
          end
        end
      end

      context "when the participant is already enrolled at the school and training" do
        let(:already_enrolled_at_school_and_training) { true }

        it "returns :cannot_add_already_enrolled_at_school" do
          expect(step.next_step).to eql :cannot_add_already_enrolled_at_school
        end
      end

      context "when the participant is an ECT" do
        let(:ect_participant) { true }

        it "returns :confirm_transfer" do
          expect(step.next_step).to eql :confirm_transfer
        end
      end

      context "when the participant is a mentor" do
        it "returns :confirm_mentor_transfer" do
          expect(step.next_step).to eql :confirm_mentor_transfer
        end
      end
    end

    context "when the dqt record matches but has a different name" do
      let(:different_name) { true }

      it "returns :known_by_another_name" do
        expect(step.next_step).to eql :known_by_another_name
      end
    end

    context "when a matching dqt record has been found" do
      let(:found_dqt_record) { true }

      include_examples "cohort and registration checks"
    end

    context "when adding a sit_mentor" do
      let(:sit_mentor) { true }
      # SIT mentor always added to current cohort
      let(:registration_open) { true }

      it "returns :none" do
        expect(step.next_step).to eql :none
      end

      context "when the cohort needs to be set up" do
        let(:need_setup) { true }

        it "returns :need_training_setup" do
          expect(step.next_step).to eql :need_training_setup
        end
      end
    end

    it "returns :still_cannot_find_their_details" do
      expect(step.next_step).to eql :still_cannot_find_their_details
    end
  end
end
