# frozen_string_literal: true

class LocalAuthorityDistrict < ApplicationRecord
  has_many :school_local_authority_districts
  has_many :schools, through: :school_local_authority_districts
  has_many :sparse_districts
end
