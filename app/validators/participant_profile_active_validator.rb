# frozen_string_literal: true

class ParticipantProfileActiveValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t("errors.participant_profile.not_active")) unless active?(value)
  end

  def active?(participant_profile)
    participant_profile&.active_record? && participant_profile&.training_status_active?
  end
end
