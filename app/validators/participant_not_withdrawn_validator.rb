# frozen_string_literal: true

class ParticipantNotWithdrawnValidator < ActiveModel::Validator
  def validate(record)
    validate_withdrawals(record)
  end

private

  def validate_withdrawals(record)
    return unless record.participant_profile.present? && (withdrawn_state = find_withdrawn_participant_state(record))

    record
      .errors
      .add(:participant_id, I18n.t(:declaration_must_be_before_withdrawal_date, withdrawal_date: withdrawn_state.created_at.rfc3339))
  end

  def find_withdrawn_participant_state(record)
    record.participant_profile
      .participant_profile_states
      .withdrawn
      .where(cpd_lead_provider: record.cpd_lead_provider)
      .where("created_at <= ?", record.declaration_date)
      .first
  end
end
