# frozen_string_literal: true

require "rails_helper"

RSpec.describe DistrictSparsity, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:local_authority_district) }
  end

  describe ":latest" do
    let!(:current_sparsity) { create(:district_sparsity) }
    let!(:previous_sparsity) { create(:district_sparsity, start_year: 2019, end_year: 2020) }

    it "includes current sparsity" do
      expect(DistrictSparsity.latest).to include(current_sparsity)
    end

    it "does not include previous sparsity" do
      expect(DistrictSparsity.latest).not_to include(previous_sparsity)
    end
  end

  describe ":for_year" do
    let!(:new_sparsity) { create(:district_sparsity, start_year: 2021) }
    let!(:existing_sparsity) { create(:district_sparsity, start_year: 2020) }
    let!(:previous_sparsity) { create(:district_sparsity, start_year: 2019, end_year: 2020) }

    it "includes existing sparsity" do
      expect(DistrictSparsity.for_year(2020)).to include(existing_sparsity)
    end

    it "does not include new sparsity" do
      expect(DistrictSparsity.for_year(2020)).not_to include(new_sparsity)
    end

    it "does not include previous sparsity" do
      expect(DistrictSparsity.for_year(2020)).not_to include(previous_sparsity)
    end

    it "includes previous sparsity for the correct year" do
      expect(DistrictSparsity.for_year(2019)).to include(previous_sparsity)
    end
  end
end
