# frozen_string_literal: true

class ActiveParticipantProfileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t("errors.participant_profile.not_a_participant_profile")) unless participant_profile?(value)
    record.errors.add(attribute, I18n.t("errors.participant_profile.not_active")) unless active?(value)
  end

  def active?(instance)
    instance&.active_record?
  end

  def participant_profile?(instance)
    instance.is_a?(ParticipantProfile)
  end
end
