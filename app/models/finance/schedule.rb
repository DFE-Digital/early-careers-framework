# frozen_string_literal: true

class Finance::Schedule < ApplicationRecord
  has_many :milestones
  has_many :participant_profiles
end
