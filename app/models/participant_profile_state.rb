# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  belongs_to :participant_profile, touch: true
  belongs_to :cpd_lead_provider, optional: true

  enum state: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }
end
