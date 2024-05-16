# frozen_string_literal: true

require "rails_helper"

describe ParticipantProfile::ECT, type: :model do
  let(:instance) { described_class.new }

  describe "associations" do
    it { is_expected.to belong_to(:mentor_profile).class_name("ParticipantProfile::Mentor").optional }
    it { is_expected.to have_one(:mentor).through(:mentor_profile).source(:user) }
  end

  describe "callbacks" do
    it "updates the updated_at on associated mentor profile user when meaningfully updated" do
      freeze_time
      profile = create(:ect_participant_profile, updated_at: 2.weeks.ago)
      user = profile.user
      user.update!(updated_at: 2.weeks.ago)

      profile.update!(updated_at: Time.zone.now - 1.day)

      expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    end

    it "does not update the updated_at on associated mentor profile user when not changed" do
      freeze_time
      profile = create(:ect_participant_profile, updated_at: 2.weeks.ago)
      user = profile.user
      user.update!(updated_at: 2.weeks.ago)

      profile.save!

      expect(user.reload.updated_at).to be_within(1.second).of 2.weeks.ago
    end
  end

  describe "#ect?" do
    it { expect(instance).to be_ect }
  end

  describe "#participant_type" do
    it { expect(instance.participant_type).to eq(:ect) }
  end

  describe "#role" do
    it { expect(instance.role).to eq("Early career teacher") }
  end

  include_context "can change cohort and continue training", :ect_participant_declaration, :induction_completion_date
end
