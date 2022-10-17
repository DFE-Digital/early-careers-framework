# frozen_string_literal: true

RSpec.describe Finance::ECF::ChangeTrainingStatusForm, :with_default_schedules, type: :model do
  subject(:form) { described_class.new(params) }

  let(:cpd_lead_provider)        { create(:cpd_lead_provider, :with_lead_provider) }
  let(:params)                   { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

  describe "EarlyCareerTeacher" do
    let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }
    let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(ParticipantProfile::DEFERRAL_REASONS) }

    describe ".save" do
      context "valid params" do
        it "should change training status" do
          expect(form.save).to be true
          expect(participant_profile.reload).to be_training_status_deferred
        end
      end

      context "invalid params" do
        let(:params) { { participant_profile:, training_status: nil, reason: nil } }

        it "should not change training status" do
          expect(form.save).to be false
          expect(participant_profile.reload).to be_training_status_active
        end
      end
    end
  end

  describe "Mentor" do
    let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, cpd_lead_provider:) }
    let(:participant_profile)      { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(ParticipantProfile::DEFERRAL_REASONS) }

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
