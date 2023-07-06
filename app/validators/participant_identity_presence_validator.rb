# frozen_string_literal: true

class ParticipantIdentityPresenceValidator < ActiveModel::Validator
  def validate(record)
    return if record.errors.any?

    has_participant_identity?(record)
  end

private

  def has_participant_identity?(record)
    return if record.participant_identity.present?

    record.errors.add(:participant_id, I18n.t(:invalid_participant))
  end
end
