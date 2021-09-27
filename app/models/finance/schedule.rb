# frozen_string_literal: true

class Finance::Schedule < ApplicationRecord
  has_many :milestones, -> { order(milestone_date: :asc) }
  has_many :participant_profiles

  def self.default_ecf
    find_by(name: "ECF September standard 2021")
  end

  def self.default_npq_leadership
    find_by(name: "NPQ Leadership November 2021")
  end

  def self.default_npq_specialist
    find_by(name: "NPQ Specialist November 2021")
  end
end
