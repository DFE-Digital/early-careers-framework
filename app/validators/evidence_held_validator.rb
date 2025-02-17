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
    else
      []
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
    else
      []
    end
  end

  def validate(record)
    return if record.errors.any?

    if cohort_with_detailed_evidence_types?(record)
      return unless validate_detailed_evidence_held?(record)

      evidence_held_present?(record)
      valid_detailed_evidence_held?(record)
    else
      return unless validate_evidence_held?(record)

      evidence_held_present?(record)
      valid_evidence_held?(record)
    end
  end

private

  def cohort_with_detailed_evidence_types?(record)
    return unless record.schedule && record.cohort

    record.cohort.detailed_evidence_types?
  end

  def validate_evidence_held?(record)
    return unless record.participant_profile && record.participant_profile.is_a?(ParticipantProfile::ECF)

    record.declaration_type.present? && record.declaration_type != "started"
  end

  def validate_detailed_evidence_held?(record)
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
    return if record.evidence_held.in?(record.participant_profile.class::VALID_EVIDENCE_HELD)

    record.errors.add(:evidence_held, I18n.t(:invalid_evidence_type))
  end

  def valid_detailed_evidence_held?(record)
    return if record.errors.any?

    evidences = if record.participant_profile.ect?
                  ect_evidences(record.declaration_type)
                else
                  mentor_evidences(record.declaration_type)
                end
    return if record.evidence_held.in?(evidences)

    record.errors.add(:evidence_held, I18n.t(:invalid_evidence_type))
  end
end
