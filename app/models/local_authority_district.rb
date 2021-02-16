# frozen_string_literal: true

class LocalAuthorityDistrict < ApplicationRecord
  has_many :school_local_authority_districts
  has_many :schools, through: :school_local_authority_districts
  has_many :district_sparsities

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
