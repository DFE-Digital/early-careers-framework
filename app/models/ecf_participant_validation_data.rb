# frozen_string_literal: true

class ECFParticipantValidationData < ApplicationRecord
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true

  def can_validate_participant?
    date_of_birth.present? && (trn.present? || nino.present?)
  end
end
