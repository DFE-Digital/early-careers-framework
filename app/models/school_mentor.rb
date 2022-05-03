# frozen_string_literal: true

class SchoolMentor < ApplicationRecord
  belongs_to :school
  belongs_to :participant_profile, class_name: "ParticipantProfile::Mentor"
  belongs_to :preferred_identity, class_name: "ParticipantIdentity"
end
