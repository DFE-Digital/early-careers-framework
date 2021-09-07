# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnership, type: :model do
  subject(:partnership) { build(:partnership) }

  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:delivery_partner) }
    it { is_expected.to have_many(:partnership_notification_emails) }
  end

  it "updates the updated_at on participant profiles and users" do
    freeze_time
    school_cohort = create(:school_cohort)
    partnership = create(:partnership, school: school_cohort.school)
    profile = create(:participant_profile, :ect, school_cohort: school_cohort, updated_at: 2.weeks.ago)
    user = profile.user
    user.update!(updated_at: 2.weeks.ago)

    partnership.update!(updated_at: 2.weeks.ago)

    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    expect(profile.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  describe "#challenged?" do
    it "returns true when the partnership has been challenged" do
      partnership = build(:partnership, challenged_at: Time.zone.now, challenge_reason: "mistake")

      expect(partnership.challenged?).to eq true
    end

    it "returns false when the partnership has not been challenged" do
      expect(partnership.challenged?).to eq false
    end
  end

  describe "scope :unchallenged" do
    let!(:challenged_partnership) { create(:partnership, challenged_at: Time.zone.now, challenge_reason: "mistake") }
    before { partnership.save! }

    it "includes unchallenged partnerships" do
      expect(Partnership.unchallenged).to include(partnership)
    end

    it "does not include challenged partnerships" do
      expect(Partnership.unchallenged).not_to include(challenged_partnership)
    end
  end

  describe "#challenge!" do
    it "sets the challenge reason and challenged at time" do
      freeze_time
      partnership.challenge!("mistake")

      expect(partnership.challenge_reason).to eql "mistake"
      expect(partnership.challenged_at).to eql Time.zone.now
    end

    it "raises an error when given a bad argument" do
      expect {
        partnership.challenge!("bad_argument")
      }.to raise_error ArgumentError
    end

    it "raises an error when given a blank argument" do
      expect {
        partnership.challenge!("")
      }.to raise_error ArgumentError
    end
  end

  describe "#in_challenge_window?" do
    it "returns true when the challenge deadline is ahead" do
      partnership = create(:partnership, challenge_deadline: rand(1..100).days.from_now)

      expect(partnership).to be_in_challenge_window
    end

    it "returns false when the challenge deadline has lapsed" do
      partnership = create(:partnership, challenge_deadline: rand(1..100).days.ago)

      expect(partnership).not_to be_in_challenge_window
    end
  end

  describe "scope :active" do
    let!(:pending_partnership) { create(:partnership, :pending) }
    let!(:partnership) { create(:partnership) }
    let!(:challenged_partnership) { create(:partnership, :challenged, :pending) }

    it "returns only unchallenged, not pending partnerships" do
      expect(Partnership.active).to contain_exactly(partnership)
    end
  end
end
