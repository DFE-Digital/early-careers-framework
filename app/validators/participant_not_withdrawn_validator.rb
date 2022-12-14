# frozen_string_literal: true

class ParticipantNotWithdrawnValidator < ActiveModel::Validator
  def validate(record)
    validate_withdrawals(record)
  end

private

  def validate_withdrawals(record)
    return unless record.participant_profile.present? && (latest_state = latest_participant_state(record))
    return unless latest_state.withdrawn? && latest_state.created_at <= record.declaration_date

    record
      .errors
      .add(:participant_id, I18n.t(:declaration_must_be_before_withdrawal_date, withdrawal_date: latest_state.created_at.rfc3339))
  end

  def latest_participant_state(record)
    record.participant_profile
      .participant_profile_states
      .where(cpd_lead_provider: record.cpd_lead_provider)
      .most_recent
      .first
  end
end
