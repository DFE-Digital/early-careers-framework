# frozen_string_literal: true

module Finance
  class Schedule < ApplicationRecord
    belongs_to :cohort
    has_many :schedule_milestones, class_name: "Finance::ScheduleMilestone"
    has_many :milestones, -> { order(milestone_date: :asc) } # TODO: add this in a later PR, through: :schedule_milestones
    has_many :participant_profiles

    validates :schedule_identifier, presence: true

    # cohort_start_year
    delegate :start_year, to: :cohort, prefix: true

    def npq?
      false
    end
  end
end

require "finance/schedule/ecf"
require "finance/schedule/npq"
