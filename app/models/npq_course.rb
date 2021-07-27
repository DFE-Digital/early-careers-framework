# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_profiles

  class << self
    def identifiers
      pluck(:identifier)
    end
  end
end
