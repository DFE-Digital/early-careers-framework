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

  describe ".exceeding_percentage" do
    let(:school) { create(:school) }

    let!(:less_than_40) { create(:pupil_premium, eligible_pupils: 39, total_pupils: 100, school:) }
    let!(:equal_to_40) { create(:pupil_premium, eligible_pupils: 40, total_pupils: 100, school:) }
    let!(:greater_than_40) { create(:pupil_premium, eligible_pupils: 41, total_pupils: 100, school:) }

    it("has a default threshold of 40%") { expect(PupilPremium::THRESHOLD_PERCENTAGE).to eql(40) }

    it "includes pupil premium records with more than 40%" do
      expect(PupilPremium.exceeding_percentage).to include(greater_than_40)
    end

    it "includes pupil premium records that equal 40%" do
      expect(PupilPremium.exceeding_percentage).to include(equal_to_40)
    end

    it "doesn't include pupil premium records are less than 40%" do
      expect(PupilPremium.exceeding_percentage).not_to include(less_than_40)
    end

    context "when the threshold is overridden" do
      it "includes pupil premium records that exceed the provided threshold" do
        expect(PupilPremium.exceeding_percentage(threshold: 37)).to include(less_than_40)
      end
    end
  end

  describe "scopes" do
    describe ".with_pupils" do
      let!(:school_with_no_pupils) { create(:school) }
      let!(:school_with_pupils) { create(:school) }

      let!(:pupil_premium_with_no_pupils) { create(:pupil_premium, :no_pupils, school: school_with_no_pupils) }
      let!(:pupil_premium_with_pupils) { create(:pupil_premium, school: school_with_pupils) }

      it "does not include results with no pupils" do
        expect(PupilPremium.with_pupils).not_to include(*school_with_no_pupils.pupil_premiums)
        expect(PupilPremium.with_pupils).to include(*school_with_pupils.pupil_premiums)
      end
    end

    describe ".with_start_year" do
      let!(:school) { create(:school) }

      let!(:pupil_premium_2021) { create(:pupil_premium, start_year: 2021, school:) }
      let!(:pupil_premium_2022) { create(:pupil_premium, start_year: 2022, school:) }

      it "only includes results with with a matching year" do
        expect(PupilPremium.with_start_year(2021)).to include(pupil_premium_2021)
        expect(PupilPremium.with_start_year(2021)).not_to include(pupil_premium_2022)
      end
    end

    describe ".only_with_uplift" do
      let(:uplifted_school) { create(:school, :pupil_premium_uplift) }
      let(:not_uplifted_school) { create(:school, pupil_premiums: [build(:pupil_premium, :not_eligible)]) }

      it "returns uplifted eligibilities" do
        expect(PupilPremium.only_with_uplift(2021)).to include(*uplifted_school.pupil_premiums)
        expect(PupilPremium.only_with_uplift(2021)).not_to include(*not_uplifted_school.pupil_premiums)
      end
    end
  end
end
