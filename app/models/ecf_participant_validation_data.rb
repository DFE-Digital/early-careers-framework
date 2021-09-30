# frozen_string_literal: true

class ECFParticipantValidationData < ApplicationRecord
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
end
