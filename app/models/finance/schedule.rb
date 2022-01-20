# frozen_string_literal: true

class Finance::Schedule < ApplicationRecord
  belongs_to :cohort

  has_many :milestones, -> { order(milestone_date: :asc) }
  has_many :participant_profiles

  validates :schedule_identifier, presence: true
end
