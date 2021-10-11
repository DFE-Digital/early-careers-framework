# frozen_string_literal: true

class ParticipantProfileSchedule < ApplicationRecord
  belongs_to :participant_profile
  belongs_to :schedule, class_name: "Finance::Schedule"

  scope :most_recent, -> { order("created_at desc").limit(1) }
end
