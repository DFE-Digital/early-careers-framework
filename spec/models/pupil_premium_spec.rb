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
    it "should be true when pupil_premium_incentive is true" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 41,
        total_pupils: 100,
        pupil_premium_incentive: true,
      )

      expect(pupil_premium).to be_uplift
    end

    it "should be false when pupil_premium_incentive is false" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 39,
        total_pupils: 100,
      )

      expect(pupil_premium).not_to be_uplift
    end
  end

  describe "#sparse?" do
    it "should be true when sparsity_incentive is true" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 41,
        total_pupils: 100,
        sparsity_incentive: true,
      )

      expect(pupil_premium).to be_sparse
    end

    it "should be false when sparsity_incentive is false" do
      pupil_premium = PupilPremium.new(
        eligible_pupils: 39,
        total_pupils: 100,
      )

      expect(pupil_premium).not_to be_sparse
    end
  end

  describe "scopes" do
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
      let(:not_uplifted_school) { create(:school, pupil_premiums: [build(:pupil_premium)]) }

      it "returns uplifted eligibilities" do
        expect(PupilPremium.only_with_uplift(2021)).to include(*uplifted_school.pupil_premiums)
        expect(PupilPremium.only_with_uplift(2021)).not_to include(*not_uplifted_school.pupil_premiums)
      end
    end

    describe ".only_with_sparsity" do
      let(:sparse_school) { create(:school, :sparsity_uplift) }
      let(:not_sparse_school) { create(:school, pupil_premiums: [build(:pupil_premium)]) }

      it "returns uplifted eligibilities" do
        expect(PupilPremium.only_with_sparsity(2021)).to include(*sparse_school.pupil_premiums)
        expect(PupilPremium.only_with_sparsity(2021)).not_to include(*not_sparse_school.pupil_premiums)
      end
    end
  end
end
