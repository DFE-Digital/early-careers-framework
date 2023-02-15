# frozen_string_literal: true

class ECFParticipantEligibility < ApplicationRecord
  has_paper_trail

  enum reason: {
    active_flags: "active_flags",
    previous_participation: "previous_participation",
    previous_induction: "previous_induction",
    no_qts: "no_qts",
    different_trn: "different_trn",
    duplicate_profile: "duplicate_profile",
    none: "none",
    no_induction: "no_induction",
    exempt_from_induction: "exempt_from_induction",
  }, _suffix: true

  enum status: {
    eligible: "eligible",
    matched: "matched",
    manual_check: "manual_check",
    ineligible: "ineligible",
  }, _suffix: true

  # Associations
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true

  # Validations
  validates :status, presence: true
  validates :reason, presence: true

  # Scopes
  scope :updated_before, ->(timestamp) { where(updated_at: ..timestamp) }

  # Instance Methods
  def duplicate_profile?
    participant_profile.mentor? && participant_profile.secondary_profile?
  end

  def ineligible_and_duplicated_or_previously_participated?
    ineligible_status? && (previous_participation_reason? || duplicate_profile_reason?)
  end

  def ineligible_but_not_duplicated_or_previously_participated?
    ineligible_status? && !(previous_participation_reason? || duplicate_profile_reason?)
  end
end
