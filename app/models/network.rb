# frozen_string_literal: true

class Network < ApplicationRecord
  has_many :schools

  scope :with_name_like, lambda { |search_key|
    where("name ILIKE ?", "%#{search_key}%")
  }
end
