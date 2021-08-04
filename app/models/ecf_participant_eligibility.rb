# frozen_string_literal: true

class ECFParticipantEligibility < ApplicationRecord
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  before_validation :determine_status

  enum status: {
    eligible: "eligible",
    matched: "matched",
    manual_check: "manual_check",
  }, _suffix: true

  def determine_status
    self.status = if active_flags? || previous_participation? || previous_induction?
                    :manual_check
                  elsif !qts?
                    :matched
                  else
                    # NOTE: this should be :eligible here but we are putting
                    # everyone in the holding pen until we have the data to validate further
                    :matched
                  end
  end
end
