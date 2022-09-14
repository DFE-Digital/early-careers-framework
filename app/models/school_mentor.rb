# frozen_string_literal: true

class SchoolMentor < ApplicationRecord
  belongs_to :school
  belongs_to :participant_profile, class_name: "ParticipantProfile::Mentor"
  belongs_to :preferred_identity, class_name: "ParticipantIdentity"

  scope :to_be_removed, -> { where(remove_from_school_on: ..Time.zone.today) }
end
