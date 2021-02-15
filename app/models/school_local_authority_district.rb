# frozen_string_literal: true

class SchoolLocalAuthorityDistrict < ApplicationRecord
  belongs_to :school
  belongs_to :local_authority_district

  scope :latest, -> { where(end_year: nil) }
end
