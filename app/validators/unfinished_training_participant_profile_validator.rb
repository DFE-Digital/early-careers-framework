# frozen_string_literal: true

class UnfinishedTrainingParticipantProfileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t("errors.participant_profile.not_a_participant_profile")) unless participant_profile?(value)
    record.errors.add(attribute, I18n.t("errors.participant_profile.training_complete")) if completed_training?(value)
  end

  def participant_profile?(instance)
    instance.is_a?(ParticipantProfile)
  end

  def completed_training?(instance)
    instance&.completed_training?
  end
end
