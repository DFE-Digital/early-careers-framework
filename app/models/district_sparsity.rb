# frozen_string_literal: true

class DistrictSparsity < ApplicationRecord
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }
  scope :for_year, lambda { |year|
    query = <<~SQLSNIPPET
      district_sparsities.start_year <= ?
          AND (district_sparsities.end_year > ?
              OR district_sparsities.end_year IS NULL)
    SQLSNIPPET
    where(query, year, year)
  }
end
