# frozen_string_literal: true

RSpec.describe Finance::ECF::ChangeTrainingStatusForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:school_cohort) { participant_profile.school_cohort }
  let!(:partnership) do
    create(
      :partnership,
      school: school_cohort.school,
      cohort: school_cohort.cohort,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let(:induction_programme) { create(:induction_programme, partnership:, school_cohort:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }
  let(:params) { { participant_profile:, training_status: "deferred", reason: "bereavement" } }

  describe "EarlyCareerTeacher" do
    let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, user: participant_profile.user) }
    let(:participant_profile) { create(:ect_participant_profile, training_status: "active") }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::ECF.reasons) }

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
    let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, user: participant_profile.user) }
    let(:participant_profile) { create(:mentor_participant_profile, training_status: "active") }

    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(Participants::Defer::ECF.reasons) }

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
