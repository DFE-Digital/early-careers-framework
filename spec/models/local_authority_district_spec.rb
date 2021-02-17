# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalAuthorityDistrict, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:district_sparsities) }
    it { is_expected.to have_many(:school_local_authority_districts) }
    it { is_expected.to have_many(:schools).through(:school_local_authority_districts) }
  end

  describe "#sparse?" do
    context "when the district is sparse" do
      let(:district) { create(:local_authority_district, :sparse) }

      it "returns true" do
        expect(district.sparse?).to be true
      end
    end

    context "when the district is not sparse" do
      let(:district) { create(:local_authority_district) }

      it "returns false" do
        expect(district.sparse?).to be false
      end
    end

    context "when the district was previously sparse" do
      let(:district) do
        create(
          :local_authority_district,
          district_sparsities: [build(:district_sparsity, start_year: 2020, end_year: 2021)],
        )
      end

      it "returns false" do
        expect(district.sparse?).to be false
      end

      it "returns true for the sparse year" do
        expect(district.sparse?(2020)).to be true
      end
    end
  end

  describe "scope :only_with_uplift" do
    let!(:new_sparsity) { create(:local_authority_district, district_sparsities: [build(:district_sparsity, start_year: 2021)]) }
    let!(:existing_sparsity) { create(:local_authority_district, district_sparsities: [build(:district_sparsity, start_year: 2020)]) }
    let!(:previous_sparsity) { create(:local_authority_district, district_sparsities: [build(:district_sparsity, start_year: 2019, end_year: 2020)]) }

    it "includes existing sparsity" do
      expect(LocalAuthorityDistrict.only_with_uplift(2020)).to include(existing_sparsity)
    end

    it "does not include new sparsity" do
      expect(LocalAuthorityDistrict.only_with_uplift(2020)).not_to include(new_sparsity)
    end

    it "does not include previous sparsity" do
      expect(LocalAuthorityDistrict.only_with_uplift(2020)).not_to include(previous_sparsity)
    end

    it "includes previous sparsity for the correct year" do
      expect(LocalAuthorityDistrict.only_with_uplift(2019)).to include(previous_sparsity)
    end
  end
end
