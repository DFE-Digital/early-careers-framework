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

  describe "#challenge_deadline" do
    it "returns the correct value" do
      travel_to Time.zone.parse("01/01/2020 13:00")

      partnership = create(:partnership)
      expect(partnership.challenge_deadline).to eql Time.zone.parse("15/01/2020 13:00")
    end

    it "can be overridden" do
      travel_to Time.zone.parse("01/01/2020 13:00")
      expected_deadline = Time.zone.parse("02/01/2020 13:00")

      partnership = Partnership.create!(
        lead_provider: create(:lead_provider),
        delivery_partner: create(:delivery_partner),
        cohort: create(:cohort),
        school: create(:school),
        challenge_deadline: expected_deadline,
      )
      expect(partnership.challenge_deadline).to eql expected_deadline
    end
  end

  describe "#in_challenge_window?" do
    it "returns true when the partnership is less than 14 days old" do
      partnership = create(:partnership)

      travel 13.days

      expect(partnership.in_challenge_window?).to eq true
    end

    it "returns false when the partnership is more than 14 days old" do
      partnership = create(:partnership)

      travel 15.days

      expect(partnership.in_challenge_window?).to eq false
    end
  end
end
