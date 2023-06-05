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

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:lead_provider).with_prefix(true).allow_nil }
    it { is_expected.to delegate_method(:name).to(:delivery_partner).with_prefix(true).allow_nil }
  end

  it "updates the updated_at on participant profiles and users", :with_default_schedules do
    freeze_time
    school_cohort = create(:school_cohort)
    partnership = create(:partnership, school: school_cohort.school)
    profile = create(:ect, school_cohort:, updated_at: 2.weeks.ago)
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

  describe "#in_challenge_window?" do
    it "returns true when the challenge deadline is ahead" do
      partnership = create(:partnership, challenge_deadline: rand(1..100).days.from_now)

      expect(partnership).to be_in_challenge_window
    end

    it "returns false when the challenge deadline has lapsed" do
      partnership = create(:partnership, challenge_deadline: rand(1..100).days.ago)

      expect(partnership).not_to be_in_challenge_window
    end

    it "returns false when the challenge_deadline is blank" do
      partnership = create(:partnership, challenge_deadline: nil)

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

  it "updates analytics when any attributes changes", :with_default_schedules do
    partnership = create(:partnership, pending: true)
    partnership.pending = false
    expect {
      partnership.save!
    }.to have_enqueued_job(Analytics::UpsertECFPartnershipJob).with(
      partnership:,
    )
  end

  describe "#unchallenge!" do
    let!(:partnership) { build(:partnership, challenged_at: Time.zone.now, challenge_reason: :mistake) }

    it "clears challenged_at and challenge_reason and sets challenge_deadline" do
      expect(partnership.challenged?).to be_truthy

      partnership.unchallenge!

      aggregate_failures do
        expect(partnership.challenged_at).to be_blank
        expect(partnership.challenge_reason).to be_blank
        expect(partnership.challenge_deadline).to eq(partnership.cohort.academic_year_start_date + 2.months)
        expect(partnership.challenged?).to be_falsey
      end
    end
  end

  describe "challenge deadline for cohort 2023" do
    it "sets the challenge deadline to 31st October 2023 when the date is before 17th October 2023" do
      travel_to Date.new(2023, 10, 16) do
        partnership = create(:partnership, cohort: create(:cohort, start_year: 2023))
        expect(partnership.challenge_deadline).to eq(Date.new(2023, 10, 31))
      end
    end

    it "leaves the challenge deadline to the default value when the date is from 17th October 2023" do
      travel_to Date.new(2023, 10, 17) do
        partnership = create(:partnership, cohort: create(:cohort, start_year: 2023))
        expect(partnership.challenge_deadline).to_not eq(Date.new(2023, 10, 31))
      end
    end
  end
end
