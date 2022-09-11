# frozen_string_literal: true

class ECFParticipantValidationData < ApplicationRecord
  self.table_name = "ecf_participant_validation_data"

  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
end
