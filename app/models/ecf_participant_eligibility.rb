# frozen_string_literal: true

class ECFParticipantEligibility < ApplicationRecord
  has_paper_trail

  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  before_validation :determine_status, on: :create

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
    none: "none",
  }, _suffix: true

  def determine_status
    self.status, self.reason = if active_flags?
                                 %i[manual_check active_flags]
                               elsif previous_participation? # ERO mentors
                                 %i[manual_check previous_participation]
                               elsif previous_induction? && participant_profile.ect?
                                 %i[manual_check previous_induction]
                               elsif !qts?
                                 %i[matched no_qts]
                               else
                                 %i[eligible none]
                               end
  end
end
