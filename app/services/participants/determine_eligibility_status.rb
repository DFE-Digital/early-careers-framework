# frozen_string_literal: true

##
# Determine the +status+ and +reason+ for a participant's +ECFParticipantEligibility+ record
# Uses the flags stored on the +ECFParticipantEligibility+ and related info from the
# associated +ParticipantProfile+
# If the +manually_validated+ attribute is set then the eligibility will not be re-evaluated. Use the <tt>force_validation: true</tt>
# param to override this behaviour.
#
# == Parameters
# @param :ecf_participant_eligibility [ECFParticipantEligibility] the record to determine eligibilty for
# @param :save_record [Boolean] whether to save the record after setting the +status+ and +reason+ attributes. Default is +true+
# @param :force_validation [Boolean] override the +manually_validated+ guard flag if set. Default is +false+
#
# == Usage:
# <tt>Participants::DetermineEligibilityStatus.call(ecf_participant_eligibility: eligibility_record)</tt>
#
class Participants::DetermineEligibilityStatus < BaseService
  delegate :active_flags?,
           :previous_participation?,
           :previous_induction?,
           :qts?,
           :different_trn?,
           :exempt_from_induction?,
           :no_induction?,
           :manually_validated?,
           :duplicate_profile?,
           :participant_profile,
           to: :participant_eligibility

  def call
    return nil if participant_eligibility.nil?

    if revalidate_status?
      status, reason = if active_flags?
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

      participant_eligibility.manually_validated = false
      participant_eligibility.status = status
      participant_eligibility.reason = reason
    end

    # there might be updates to save even if we don't re-evaluate status
    participant_eligibility.save! if save_record
  end

private

  attr_reader :participant_eligibility, :save_record, :force_validation

  def initialize(ecf_participant_eligibility:, save_record: true, force_validation: false)
    @participant_eligibility = ecf_participant_eligibility
    @save_record = save_record
    @force_validation = force_validation
  end

  def revalidate_status?
    force_validation || !manually_validated?
  end
end
