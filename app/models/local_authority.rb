# frozen_string_literal: true

class LocalAuthority < ApplicationRecord
  has_many :school_local_authorities
  has_many :schools, through: :school_local_authorities
end
