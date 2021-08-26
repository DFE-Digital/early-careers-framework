# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  belongs_to :participant_profile
  enum state: {
    active: "active",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }
end
