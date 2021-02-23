# frozen_string_literal: true

class LocalAuthority < ApplicationRecord
  has_many :school_local_authorities
  has_many :schools, through: :school_local_authorities

  scope :with_name_like, lambda { |search_key|
    where("name ILIKE ?", "%#{search_key}%")
  }
end
