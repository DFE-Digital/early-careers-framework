# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  belongs_to :participant_profile
  belongs_to :participant_declaration

  scope :ect_profiles, -> { where(participant_profile_id: ParticipantProfile::ECT.select(:id)) }
  scope :mentor_profiles, -> { where(participant_profile_id: ParticipantProfile::Mentor.select(:id)) }
  scope :uplift, -> { where(participant_profile_id: ParticipantProfile.uplift.select(:id)) }
end
