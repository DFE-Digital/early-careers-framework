# frozen_string_literal: true

class DistrictSparsity < ApplicationRecord
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }

  def self.for_year(year)
    start_year = arel_table[:start_year]
    end_year = arel_table[:end_year]

    where(start_year.lteq(year).and(end_year.gt(year).or(end_year.eq(nil))))
  end
end
