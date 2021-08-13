# frozen_string_literal: true

class Finance::Schedule < ApplicationRecord
  has_many :milestones, -> { order(milestone_date: :asc) }
  has_many :participant_profiles

  def self.default
    find_by(name: "ECF September standard 2021")
  end
end
