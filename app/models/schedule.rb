# frozen_string_literal: true

class Schedule < ApplicationRecord
  has_many :milestones
  has_many :participant_profiles
end
