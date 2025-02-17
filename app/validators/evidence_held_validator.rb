# frozen_string_literal: true

class EvidenceHeldValidator < ActiveModel::Validator
  def mentor_evidences(declaration_type)
    case declaration_type
    when "started"
      %w[
        training-event-attended
        self-study-material-completed
        materials-engaged-with-offline
        other
      ]
    when "completed"
      %w[
        75-percent-engagement-met
        75-percent-engagement-met-reduced-induction
      ]
    end
  end

  def ect_evidences(declaration_type)
    case declaration_type
    when "started", "retained-1", "retained-3", "retained-4", "extended-1", "extended-2", "extended-3"
      %w[
        training-event-attended
        self-study-material-completed
        materials-engaged-with-offline
        other
      ]
    when "retained-2"
      %w[
        75-percent-engagement-met
        75-percent-engagement-met-reduced-induction
      ]
    when "completed"
      %w[
        75-percent-engagement-met
        75-percent-engagement-met-reduced-induction
        one-term-induction
      ]
    end
  end

  def validate(record)
    return if record.errors.any?
    return unless validate_evidence_held?(record)

    evidence_held_present?(record)
    valid_evidence_held?(record)
  end

private

  def validate_evidence_held?(record)
    return if record.declaration_type == "started" && record.evidence_held.blank?

    record.participant_profile && record.participant_profile.is_a?(ParticipantProfile::ECF)
  end

  def evidence_held_present?(record)
    return if record.errors.any?
    return if record.evidence_held.present?

    record.errors.add(:evidence_held, I18n.t(:missing_evidence_held))
  end

  def valid_evidence_held?(record)
    return if record.errors.any?

    method = record.participant_profile.ect? ? :ect_evidences : :mentor_evidences
    return if record.evidence_held.in?(send(method, record.declaration_type) || [])

    record.errors.add(:evidence_held, I18n.t(:invalid_evidence_type))
  end
end
