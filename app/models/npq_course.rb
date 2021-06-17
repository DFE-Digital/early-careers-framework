# frozen_string_literal: true

class NpqCourse < ApplicationRecord
  has_many :npq_profiles
end
