# frozen_string_literal: true

class InductionRecordValidator < ActiveModel::Validator
  def validate(record)
    has_a_participant_identity(record)
    has_an_induction_record_for_given_provider(record)
  end

private

  def has_a_participant_identity(record)
    return if record.participant_identity && record.participant_profile

    record.errors.add(:participant_id, I18n.t(:invalid_participant))
  end

  def has_an_induction_record_for_given_provider(record)
    if record.participant_profile.is_a?(ParticipantProfile::ECF) && !relevant_induction_record?(record)
      record.errors.add(:participant_id, I18n.t(:invalid_participant))
    end
  end

  def relevant_induction_record?(record)
    Induction::FindBy.call(participant_profile: record.participant_profile,
                           lead_provider: record.cpd_lead_provider.lead_provider,
                           schedule: record.schedule).present?
  end
end
