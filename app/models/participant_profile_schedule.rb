# frozen_string_literal: true

class ParticipantProfileSchedule < ApplicationRecord
  belongs_to :participant_profile

  scope :most_recent, -> { order("created_at desc").limit(1) }
end
