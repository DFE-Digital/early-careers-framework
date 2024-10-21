# frozen_string_literal: true

class ParticipantAppropriateBodyDQTCheck < ApplicationRecord
  belongs_to :participant_profile

  # Prioritise the leading school of the AB, then the AB name and finaly nil if the participant doesn't have any AB.
  # That's because for some reasone DQT returns the leading school as the Appropriate Body name if available.
  def normalised_appropriate_body_name
    appropriate_body_name&.match(/\(([^)]+)\)/)&.captures&.first || appropriate_body_name
  end
end
