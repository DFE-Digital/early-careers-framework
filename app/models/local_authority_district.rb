# frozen_string_literal: true

class LocalAuthorityDistrict < ApplicationRecord
  has_many :school_local_authority_districts
  has_many :schools, through: :school_local_authority_districts
  has_many :district_sparsities
  # There is no link here to local_authority because this data is an export from "Get Information About Schools" and we haven't had a need to reconstruct the link

  def sparse?(year = nil)
    if year.nil?
      district_sparsities.latest.any?
    else
      district_sparsities.for_year(year).any?
    end
  end

  scope :only_with_uplift, lambda { |year|
    joins(:district_sparsities)
      .merge(DistrictSparsity.for_year(year))
  }
end
