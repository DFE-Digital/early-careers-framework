# frozen_string_literal: true

class ParticipantProfile::NPQ < ParticipantProfile
  belongs_to :school, optional: true
end
