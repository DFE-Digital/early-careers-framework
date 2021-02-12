# frozen_string_literal: true

class DistrictSparsity < ApplicationRecord
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }
  scope :for_year, ->(year) { where("start_year <= ? AND end_year > ?", year, year) }
end
