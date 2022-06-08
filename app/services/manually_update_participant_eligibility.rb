# frozen_string_literal: true

class ManuallyUpdateParticipantEligibility < BaseService
  attr_reader :participant_profile, :status, :reason, :eligibility_flag_changes

  def initialize(participant_profile:, status:, reason:, eligibility_flag_changes: {})
    @participant_profile = participant_profile
    @status = status
    @reason = reason
    @eligibility_flag_changes = eligibility_flag_changes
  end

  def call
    StoreParticipantEligibility.call(participant_profile:,
                                     eligibility_options: make_eligibility_options)
  end

private

  def make_eligibility_options
    {
      manually_validated: true,
      status:,
      reason:,
    }.merge(eligibility_flag_changes || {})
  end
end
