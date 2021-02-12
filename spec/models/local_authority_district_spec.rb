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
end
