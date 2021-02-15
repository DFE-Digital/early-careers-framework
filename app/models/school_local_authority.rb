# frozen_string_literal: true

class SchoolLocalAuthority < ApplicationRecord
  belongs_to :school
  belongs_to :local_authority

  scope :latest, -> { where(end_year: nil) }
end
