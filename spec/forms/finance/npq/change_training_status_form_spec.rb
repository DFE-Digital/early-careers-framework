# frozen_string_literal: true

RSpec.describe Finance::NPQ::ChangeTrainingStatusForm, :with_default_schedules, type: :model do
  subject(:form) { described_class.new(params) }

  describe "NPQ" do
    let(:participant_profile) { create(:npq_participant_profile, training_status: "active") }
    let(:params) { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::NPQ.reasons) }

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
