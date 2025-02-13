# frozen_string_literal: true

class EvidenceHeldValidator < ActiveModel::Validator
  DECLARATION_TYPES = {
    "started" => 1,
    "retained-1" => 2,
    "retained-2" => 3,
    "retained-3" => 4,
    "retained-4" => 5,
    "completed" => 6,
    "extended-1" => 7,
    "extended-2" => 8,
    "extended-3" => 9,
  }.freeze

  VALID_EVIDENCE_HELD = {
    "training-event-attended" => 1,
    "self-study-material-completed" => 2,
    "materials-engaged-with-offline" => 3,
    "75-percent-engagement-met" => 4,
    "75-percent-engagement-met-reduced-induction" => 5,
    "one-term-induction" => 6,
    "other" => 7,
  }.freeze

  EVIDENCE_HELD_MAP = {
    "ParticipantProfile::ECT" => {
      # started
      1 => [1, 2, 3, 7],
      # retained-1
      2 => [1, 2, 3, 7],
      # retained-2
      3 => [4, 5],
      # retained-3
      4 => [1, 2, 3, 7],
      # retained-4
      5 => [1, 2, 3, 7],
      # completed
      6 => [4, 5, 6],
      # extended-1
      7 => [1, 2, 3, 7],
      # extended-2
      8 => [1, 2, 3, 7],
      # extended-3
      9 => [1, 2, 3, 7],
    },
      "ParticipantProfile::Mentor" => {
        # started
        1 => [1, 2, 3, 7],
        # completed
        5 => [4, 5],
      },
  }.freeze

  def self.evidence_held_map
    EVIDENCE_HELD_MAP.map { |sa| { sa.first => sa.last.map { |a| { DECLARATION_TYPES.key(a.first) => a.last.map { |b| VALID_EVIDENCE_HELD.key(b) } } }.reduce(&:merge) } }.reduce(&:merge)
  end

  def validate(record)
    return if record.errors.any?
    return unless validate_evidence_held?(record)

    has_evidence_held?(record)
    has_valid_evidence_held?(record)
  end

private

  def validate_evidence_held?(record)
    return if record.declaration_type == "started" && record.evidence_held.blank?

    record.participant_profile && record.participant_profile.is_a?(ParticipantProfile::ECF)
  end

  def has_evidence_held?(record)
    return if record.errors.any?
    return if record.evidence_held.present?

    record.errors.add(:evidence_held, I18n.t(:missing_evidence_held))
  end

  def has_valid_evidence_held?(record)
    return if record.errors.any?
    return if EvidenceHeldValidator.evidence_held_map.dig(record.participant_profile.type, record.declaration_type)&.include?(record.evidence_held)

    record.errors.add(:evidence_held, I18n.t(:invalid_evidence_type))
  end
end
