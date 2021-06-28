# frozen_string_literal: true

class MentorProfileDeclaration < ParticipantProfile
  include Declarable

  belongs_to :mentor_profile

  scope :unique_id, -> { select(:mentor_profile_id).distinct }
end
