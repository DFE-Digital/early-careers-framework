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

  include_context "can change cohort and continue training", :ect, :mentor, :induction_completion_date

  include_context "can archive participant profile", :mentor, :induction_completion_date do
    def create_declaration(attrs = {})
      create(:ect_participant_declaration, attrs)
    end

    def create_profile(attrs = {})
      create(:ect_participant_profile, attrs)
    end

    describe ".archivable" do
      subject { described_class.archivable }

      it "does not include participants where the induction_start_date is 1/9/<cohort_start_year> or later" do
        build_profile(cohort: eligible_cohort, induction_start_date: Date.new(eligible_cohort.start_year, 9, 1))
        build_profile(cohort: eligible_cohort, induction_start_date: Date.new(eligible_cohort.start_year + 1, 3, 1))

        eligible_participant = build_profile(cohort: eligible_cohort)

        is_expected.to contain_exactly(eligible_participant)
      end
    end
  end
end
