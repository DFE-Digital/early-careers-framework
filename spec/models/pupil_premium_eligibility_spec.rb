# frozen_string_literal: true

require "rails_helper"

RSpec.describe PupilPremiumEligibility, type: :model do
  it "can be created" do
    expect {
      PupilPremiumEligibility.create(
        school: create(:school),
        start_year: 2021,
        percent_primary_pupils_eligible: 0,
        percent_secondary_pupils_eligible: 0,
      )
    }.to change { PupilPremiumEligibility.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
  end

  describe "#uplift?" do
    it "should be true when primary percentage > 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 41,
        percent_secondary_pupils_eligible: 0,
      )

      expect(pupil_premium_eligibility.uplift?).to be true
    end

    it "should be true when primary percentage = 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 40,
        percent_secondary_pupils_eligible: 0,
      )

      expect(pupil_premium_eligibility.uplift?).to be true
    end

    it "should be false when primary percentage < 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 39.9,
        percent_secondary_pupils_eligible: 0,
      )

      expect(pupil_premium_eligibility.uplift?).to be false
    end

    it "should be true when secondary percentage > 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 0,
        percent_secondary_pupils_eligible: 41,
      )

      expect(pupil_premium_eligibility.uplift?).to be true
    end

    it "should be true when secondary percentage = 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 0,
        percent_secondary_pupils_eligible: 40,
      )

      expect(pupil_premium_eligibility.uplift?).to be true
    end

    it "should be false when secondary percentage < 40%" do
      pupil_premium_eligibility = PupilPremiumEligibility.new(
        percent_primary_pupils_eligible: 0,
        percent_secondary_pupils_eligible: 39.9,
      )

      expect(pupil_premium_eligibility.uplift?).to be false
    end
  end
end
