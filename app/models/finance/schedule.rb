# frozen_string_literal: true

class Finance::Schedule < ApplicationRecord
  has_many :milestones, -> { order(milestone_date: :asc) }
  has_many :participant_profiles

  def self.default
    find_by(name: "ECF September standard 2021")
  end

  def milestone_for_declaration_type
    {
      "started" => milestones[0],
      "retained-1" => milestones[1],
      "retained-2" => milestones[2],
      "retained-3" => milestones[3],
      "retained-4" => milestones[4],
      "completed" => milestones.last,
    }
  end
end
