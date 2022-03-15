# frozen_string_literal: true

class ECFParticipantEligibility < ApplicationRecord
  has_paper_trail

  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  before_validation :determine_status, on: :create

  scope :updated_before, ->(timestamp) { where(updated_at: ..timestamp) }

  enum status: {
    eligible: "eligible",
    matched: "matched",
    manual_check: "manual_check",
    ineligible: "ineligible",
  }, _suffix: true

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

  def duplicate_profile?
    participant_profile&.mentor? && participant_profile&.secondary_profile?
  end

  def determine_status
    unless manually_validated?
      self.status, self.reason = if active_flags?
                                   %i[manual_check active_flags]
                                 elsif previous_participation? # ERO mentors
                                   %i[ineligible previous_participation]
                                 elsif previous_induction? && participant_profile.ect?
                                   %i[ineligible previous_induction]
                                 elsif !qts? && !participant_profile.mentor?
                                   %i[manual_check no_qts]
                                 elsif different_trn?
                                   %i[manual_check different_trn]
                                 elsif duplicate_profile?
                                   %i[ineligible duplicate_profile]
                                 elsif exempt_from_induction? && participant_profile.ect?
                                   %i[ineligible exempt_from_induction]
                                 elsif no_induction? && participant_profile.ect?
                                   %i[manual_check no_induction]
                                 else
                                   %i[eligible none]
                                 end
    end
  end
end
