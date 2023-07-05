# frozen_string_literal: true

RSpec.describe Finance::NPQ::ChangeTrainingStatusForm, type: :model do
  subject(:form) { described_class.new(params) }

  describe "NPQ" do
    let(:user) { create(:participant_identity, :secondary).user }
    let(:participant_profile) { create(:npq_participant_profile, user:, training_status: "active") }
    let(:params) { { participant_profile:, training_status: "withdrawn", reason: "insufficient-capacity-to-undertake-programme" } }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(ParticipantProfile::NPQ::WITHDRAW_REASONS) }

    describe ".save" do
      context "valid params" do
        it "should change training status" do
          expect(form.save).to be true
          expect(participant_profile.reload.training_status).to eql("withdrawn")
        end
      end

      context "invalid params" do
        let(:params) { { participant_profile:, training_status: nil, reason: nil } }

        it "should not change training status" do
          expect(form.save).to be false
          expect(participant_profile.reload.training_status).to eql("active")
        end
      end

      context "defer" do
        let(:params) { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

        describe "without declarations" do
          it "is invalid returning an error message" do
            expect(participant_profile.participant_declarations).to be_empty
            expect(form.save).to be false
            expect(form.errors.messages_for(:training_status)).to include("You cannot defer an NPQ participant that has no declarations")
          end
        end

        describe "with a declaration" do
          before do
            create(:npq_participant_declaration, participant_profile:, cpd_lead_provider: participant_profile.npq_application.npq_lead_provider.cpd_lead_provider)
          end

          it "should be valid" do
            expect(participant_profile.participant_declarations).to_not be_empty
            expect(form.save).to be true
            expect(participant_profile.reload.training_status).to eql("deferred")
          end
        end
      end
    end
  end
end
