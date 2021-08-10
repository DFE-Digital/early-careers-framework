# frozen_string_literal: true

class ECFParticipantValidationData < ApplicationRecord
  belongs_to :participant_profile, touch: true
end
