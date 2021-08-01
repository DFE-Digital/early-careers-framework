# frozen_string_literal: true

class ParticipantValidationData < ApplicationRecord
  belongs_to :participant_profile, touch: true
end
