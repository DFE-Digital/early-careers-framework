# frozen_string_literal: true

class NPQCourse < ApplicationRecord
  has_many :npq_applications, class_name: "NPQApplication"

  class << self
    def identifiers
      pluck(:identifier)
    end
  end
end
