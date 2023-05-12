# frozen_string_literal: true

class ECFParticipantValidationData < ApplicationRecord
  has_paper_trail

  belongs_to :participant_profile, class_name: "ParticipantProfile", touch: true
  validate :belongs_to_ecf_participant

  self.filter_attributes += %i[full_name trn]

  def can_validate_participant?
    date_of_birth.present? && (trn.present? || nino.present?)
  end

private

  def belongs_to_ecf_participant
    return if participant_profile.blank?
    return if participant_profile.type.in?(["ParticipantProfile::ECT", "ParticipantProfile::Mentor"])

    errors.add(:participant_profile_id, "participant is not an ECT or Mentor")
  end
end
