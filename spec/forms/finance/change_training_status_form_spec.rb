# frozen_string_literal: true

RSpec.describe Finance::ChangeTrainingStatusForm, :with_default_schedules, type: :model do
  subject(:form) { described_class.new(params) }

  describe "NPQ" do
    let(:participant_profile) { create(:npq_participant_profile, training_status: "active") }
    let(:params) { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

    it { is_expected.to validate_presence_of(:training_status) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::NPQ.reasons) }

    describe ".participant_class_name" do
      it "returns participant correct class name" do
        expect(form.participant_class_name).to eql("NPQ")
      end
    end

    describe ".action_class_name" do
      it "returns correct action name" do
        expect(form.action_class_name).to eql("Defer")
      end
    end

    describe ".save" do
      context "valid params" do
        it "should change training status" do
          expect(form.save).to be true
          expect(participant_profile.reload.training_status).to eql("deferred")
        end
      end

      context "invalid params" do
        let(:params) { { participant_profile:, training_status: nil, reason: nil } }

        it "should not change training status" do
          expect(form.save).to be false
          expect(participant_profile.reload.training_status).to eql("active")
        end
      end
    end
  end

  describe "ECF" do
    let(:cpd_lead_provider)        { create(:cpd_lead_provider, :with_lead_provider) }
    let(:params)                   { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

    describe "EarlyCareerTeacher" do
      let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }
      let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }

      it { is_expected.to validate_presence_of(:training_status) }
      it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::ECF.reasons) }

      describe ".participant_class_name" do
        it "returns participant correct class name" do
          expect(form.participant_class_name).to eql("EarlyCareerTeacher")
        end
      end

      describe ".action_class_name" do
        it "returns correct action name" do
          expect(form.action_class_name).to eql("Defer")
        end
      end

      describe ".save" do
        context "valid params" do
          it "should change training status" do
            expect(form.save).to be true
            expect(participant_profile.reload.training_status).to eql("deferred")
          end
        end

        context "invalid params" do
          let(:params) { { participant_profile:, training_status: nil, reason: nil } }

          it "should not change training status" do
            expect(form.save).to be false
            expect(participant_profile.reload.training_status).to eql("active")
          end
        end
      end
    end

    describe "Mentor" do
      let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, cpd_lead_provider:) }
      let(:participant_profile)      { create(:mentor, lead_provider: cpd_lead_provider.lead_provider ) }

      it { is_expected.to validate_presence_of(:training_status) }
      it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::ECF.reasons) }

      describe ".participant_class_name" do
        it "returns participant correct class name" do
          expect(form.participant_class_name).to eql("Mentor")
        end
      end

      describe ".action_class_name" do
        it "returns correct action name" do
          expect(form.action_class_name).to eql("Defer")
        end
      end

      describe ".save" do
        context "valid params" do
          it "should change training status" do
            expect(form.save).to be true
            expect(participant_profile.reload.training_status).to eql("deferred")
          end
        end

        context "invalid params" do
          let(:params) { { participant_profile:, training_status: nil, reason: nil } }

          it "should not change training status" do
            expect(form.save).to be false
            expect(participant_profile.reload.training_status).to eql("active")
          end
        end
      end
    end
  end
end
