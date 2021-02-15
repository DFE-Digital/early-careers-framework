# frozen_string_literal: true

require "rails_helper"

RSpec.describe PupilPremium, type: :model do
  it "can be created" do
    expect {
      PupilPremium.create(
        school: create(:school),
        start_year: 2021,
        eligible_pupils: 0,
        total_pupils: 100,
      )
    }.to change { PupilPremium.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
  end

  describe "#uplift?" do
    it "should be true when percentage eligible > 40%" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 41,
        total_pupils: 100,
      )

      expect(pupil_premium.uplift?).to be true
    end

    it "should be true when percentage eligible = 40%" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 40,
        total_pupils: 100,
      )

      expect(pupil_premium.uplift?).to be true
    end

    it "should be false when percentage eligible < 40%" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 39,
        total_pupils: 100,
      )

      expect(pupil_premium.uplift?).to be false
    end
  end

  describe "scope :only_with_uplift" do
    let(:uplifted_school) { create(:school, :pupil_premium_uplift) }
    let(:not_uplifted_school) { create(:school, pupil_premiums: [build(:pupil_premium, :not_eligible)]) }

    it "returns uplifted eligibilities" do
      expect(PupilPremium.only_with_uplift(2021)).to include(uplifted_school.pupil_premiums.first)
      expect(PupilPremium.only_with_uplift(2021)).not_to include(not_uplifted_school.pupil_premiums.first)
    end
  end
end
