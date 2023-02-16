# frozen_string_literal: true

require "rails_helper"

RSpec.describe ECFParticipantValidationData, type: :model do
  it { is_expected.to belong_to(:participant_profile) }

  it "updates the updated_at on the User" do
    freeze_time
    profile = create(:ect_participant_profile)
    user = profile.user
    validation_data = profile.create_ecf_participant_validation_data!(trn: "1234567", full_name: "Gordon Banks")
    user.update!(updated_at: 2.weeks.ago)
    validation_data.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  describe "validating the associated participant profile type" do
    subject { FactoryBot.build(:seed_ecf_participant_validation_data, participant_profile:) }
    before { subject.valid? }

    context "when linked to a Mentor participant profile" do
      let(:participant_profile) { FactoryBot.create(:seed_mentor_participant_profile, :valid) }

      it "passes validation" do
        expect(subject).to be_valid
      end
    end

    context "when linked to a ECT participant profile" do
      let(:participant_profile) { FactoryBot.create(:seed_ect_participant_profile, :valid) }

      it "passes validation" do
        expect(subject).to be_valid
      end
    end

    context "when linked to a non-ECF participant profile" do
      let(:participant_profile) { FactoryBot.create(:seed_npq_participant_profile, :valid) }

      it "fails validation" do
        expect(subject).not_to be_valid
      end

      it "has an informative error message" do
        expect(subject.errors.messages[:participant_profile_id]).to include(/not an ECT or Mentor/)
      end
    end
  end
end
