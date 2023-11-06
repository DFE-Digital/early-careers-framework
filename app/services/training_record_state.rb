# frozen_string_literal: true

# validation_state:
#   different_trn
#   internal_error
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   valid
#   validation_not_started
#
# training_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_induction_training
#   eligible_for_mentor_training
#   exempt_from_induction
#   not_allowed
#   not_qualified
#   not_yet_mentoring
#   previous_induction
#   tra_record_not_found
#
# fip_funding_eligibility_state:
#   active_flags
#   checks_not_complete
#   duplicate_profile
#   eligible_for_fip_funding
#   eligible_for_mentor_funding
#   eligible_for_mentor_funding_primary
#   exempt_from_induction
#   ineligible_ero
#   ineligible_ero_primary
#   ineligible_ero_secondary
#   ineligible_secondary
#   no_induction_start
#   not_allowed
#   not_qualified
#   previous_induction
#   tra_record_not_found
#
# mentoring_state:
#   active_mentoring
#   active_mentoring_ero
#   not_a_mentor
#   not_yet_mentoring
#   not_yet_mentoring_ero
#
# training_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   completed_training
#   deferred_training
#   joining
#   leaving
#   left
#   no_longer_involved
#   not_registered_for_training
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   withdrawn_programme
#   withdrawn_training
#
# record_state:
#   active_cip_training
#   active_diy_training
#   active_fip_training
#   active_flags
#   active_mentoring
#   active_mentoring_ero
#   checks_not_complete
#   completed_training
#   deferred_training
#   different_trn
#   duplicate_profile
#   exempt_from_induction
#   internal_error
#   joining
#   leaving
#   left
#   no_induction_start
#   no_longer_involved
#   not_allowed
#   not_qualified
#   not_registered_for_training
#   not_yet_mentoring
#   not_yet_mentoring_ero
#   previous_induction
#   registered_for_cip_training
#   registered_for_diy_training
#   registered_for_fip_no_partner
#   registered_for_fip_training
#   request_for_details_delivered
#   request_for_details_failed
#   request_for_details_submitted
#   tra_record_not_found
#   validation_not_started
#   withdrawn_programme
#   withdrawn_training
class TrainingRecordState
  RECORD_STATES = %w[
    different_trn
    request_for_details_delivered
    request_for_details_failed
    request_for_details_submitted
    validation_not_started
    internal_error
    tra_record_not_found
    checks_not_complete
    active_flags
    not_allowed
    duplicate_profile
    not_qualified
    exempt_from_induction
    previous_induction
    no_induction_start
    active_mentoring_ero
    active_mentoring
    not_yet_mentoring_ero
    not_yet_mentoring
    no_longer_involved
    leaving
    left
    joining
    withdrawn_programme
    withdrawn_training
    deferred_training
    completed_training
    registered_for_fip_no_partner
    active_fip_training
    registered_for_fip_training
    registered_for_cip_training
    active_cip_training
    active_diy_training
    registered_for_diy_training
    not_registered_for_training
  ].each_with_object({}) { |v, h| h[v] = v }.freeze

  attr_reader :induction_record, :participant_profile

  delegate :id, to: :participant_profile, prefix: true

  def initialize(induction_record)
    @induction_record = induction_record
    @participant_profile = induction_record.participant_profile
  end

  def validation_state
    case validation_state_data
    in { manual_checks: true, different_trn_reason: true }
      :different_trn

    in { awaiting_validation_data: true, latest_request_for_details_delivered: true }
      :request_for_details_delivered

    in { awaiting_validation_data: true, latest_request_for_details_failed: true }
      :request_for_details_failed

    in { awaiting_validation_data: true, latest_request_for_details_submitted: true }
      :request_for_details_submitted

    in { teacher_profile_trn_present: false, participant_validation_data_blank: true }
      :validation_not_started

    in { validation_data_api_failed: true }
      :internal_error

    in { mentor: false, teacher_profile_trn_present: false }
      :tra_record_not_found

    in { validation_data_trn_present: true, teacher_profile_trn_present: false }
      :tra_record_not_found

    else
      :valid
    end
  end

  def training_eligibility_state
    case training_eligibility_state_data
    in { eligibility_blank: true, teacher_profile_trn_present: true }
      :checks_not_complete

    in { eligibility_blank: true, ect: true }
      :checks_not_complete

    in { manual_checks: true, active_reason: true }
      :active_flags

    in { ineligible: true, active_reason: true }
      :not_allowed

    in { mentored: true }
      :eligible_for_mentor_training

    in { mentor: true }
      :not_yet_mentoring

    in { ineligible: true, duplicate_profile_reason: true }
      :duplicate_profile

    in { manual_checks: true, no_qts_reason: true }
      :not_qualified

    in { ineligible: true, exempt_from_induction_reason: true }
      :exempt_from_induction

    in { ineligible: true, previous_induction_reason: true }
      :previous_induction

    in { mentor: false, teacher_profile_trn_present: false }
      :tra_record_not_found

    in { validation_data_trn_present: true, teacher_profile_trn_present: false }
      :tra_record_not_found

    else
      :eligible_for_induction_training
    end
  end

  def fip_funding_eligibility_state
    case fip_funding_eligibility_state_data
    in { eligibility_blank: true, teacher_profile_trn_present: true }
      :checks_not_complete

    in { eligibility_blank: true, ect: true }
      :checks_not_complete

    in { eligible: true, mentor: false }
      :eligible_for_fip_funding

    in { manual_checks: true, active_reason: true, eligible: false }
      :active_flags

    in { manual_checks: true, active_reason: true, mentor: false }
      :active_flags

    in { ineligible: true, active_reason: true, eligible: false }
      :not_allowed

    in { ineligible: true, active_reason: true, mentor: false }
      :not_allowed

    in { mentor: true }
      mentor_fip_funding_eligibility_state
    else
      ect_fip_funding_eligibility_state
    end
  end

  def training_state
    case training_state_data
    in { changed_training: true }
      :no_longer_involved

    in { leaving_school: true }
      :leaving

    in { left_school: true }
      :left

    in { joining_school: true }
      :joining

    in { withdrawn_participant: true }
      :withdrawn_programme

    in { withdrawn_training: true }
      :withdrawn_training

    in { deferred_training: true }
      :deferred_training

    in { completed_training: true }
      :completed_training

    else
      ect_training_state
    end
  end

  def mentoring_state
    case mentoring_state_data
    in { mentor: false }
      :not_a_mentor

    in { mentoring: true, previous_participation_reason: true }
      :active_mentoring_ero

    in { mentoring: true }
      :active_mentoring

    in { mentoring: false, previous_participation_reason: true }
      :not_yet_mentoring_ero

    else
      :not_yet_mentoring
    end
  end

  def record_state
    case record_state_data
    in { withdrawn_participant: true }
      training_state

    in { transitioning_or_not_currently_training: true, mentor: false }
      training_state

    in { validation_status_valid: false }
      validation_state

    in { eligible_for_training: false }
      training_eligibility_state

    in { on_fip: true, application_funding_state: false }
      fip_funding_eligibility_state

    in { mentor: true }
      mentoring_state

    else
      training_state
    end
  end

  def validation_status_valid?
    validation_state == :valid
  end

private

  def ect_training_state
    case ect_training_state_data
    in { on_fip: true, partnership: false }
      :registered_for_fip_no_partner

    in { on_fip: true, induction_start_date_in_past: true }
      :active_fip_training

    in { on_fip: true }
      :registered_for_fip_training

    in { on_cip: true, induction_start_date_in_past: true }
      :active_cip_training

    in { on_cip: true }
      :registered_for_cip_training

    in { on_design_our_own: true, induction_start_date_in_past: true }
      :active_diy_training

    in { on_design_our_own: true }
      :registered_for_diy_training

    else
      :not_registered_for_training
    end
  end

  def mentor_fip_funding_eligibility_state
    case mentor_fip_funding_eligibility_state_data
    in { mentor: true, ineligible: true, previous_participation_reason: true, secondary_profile: true }
      :ineligible_ero_secondary

    in { mentor: true, ineligible: true, previous_participation_reason: true, duplicate_profile_reason: true }
      :ineligible_ero_secondary

    in { mentor: true, ineligible: true, previous_participation_reason: true, primary_profile: true }
      :ineligible_ero_primary

    in { mentor: true, ineligible: true, previous_participation_reason: true }
      :ineligible_ero

    in { mentor: true, ineligible: true, secondary_profile: true }
      :ineligible_secondary

    in { mentor: true, ineligible: true, duplicate_profile_reason: true }
      :ineligible_secondary

    in { mentor: true, primary_profile: true }
      :eligible_for_mentor_funding_primary

    else
      :eligible_for_mentor_funding
    end
  end

  def ect_fip_funding_eligibility_state
    case ect_fip_funding_eligibility_state_data
    in { mentor: false, ineligible: true, duplicate_profile_reason: true }
      :duplicate_profile

    in { mentor: false, manual_checks: true, no_induction_reason: true }
      :no_induction_start

    in { mentor: false, manual_checks: true, no_qts_reason: true }
      :not_qualified

    in { mentor: false, ineligible: true, exempt_from_induction_reason: true }
      :exempt_from_induction

    in { mentor: false, ineligible: true, previous_induction_reason: true }
      :previous_induction

    in { mentor: false, teacher_profile_trn_present: false }
      :tra_record_not_found

    in { validation_data_trn_present: true, teacher_profile_trn_present: false }
      :tra_record_not_found

    else
      :eligible_for_fip_funding
    end
  end

  def validation_state_data
    @validation_state_data ||= {
      manual_checks: manual_checks?,
      different_trn_reason: different_trn_reason?,
      latest_request_for_details_delivered: latest_request_for_details_delivered?,
      latest_request_for_details_failed: latest_request_for_details_failed?,
      latest_request_for_details_submitted: latest_request_for_details_submitted?,
      validation_data_api_failed: validation_data_api_failed?,
      mentor: mentor?,
      participant_validation_data_blank: participant_validation_data_blank?,
      teacher_profile_trn_present: teacher_profile_trn_present?,
      validation_data_trn_present: validation_data_trn_present?,
      awaiting_validation_data: awaiting_validation_data?,
    }
  end

  def training_eligibility_state_data
    @training_eligibility_state_data ||= {
      eligibility_blank: eligibility_blank?,
      teacher_profile_trn_present: teacher_profile_trn_present?,
      manual_checks: manual_checks?,
      active_reason: active_reason?,
      duplicate_profile_reason: duplicate_profile_reason?,
      no_qts_reason: no_qts_reason?,
      exempt_from_induction_reason: exempt_from_induction_reason?,
      previous_induction_reason: previous_induction_reason?,
      ineligible: ineligible?,
      mentored: mentored?,
      mentor: mentor?,
      validation_data_trn_present: validation_data_trn_present?,
      ect: ect?,
    }
  end

  def fip_funding_eligibility_state_data
    @fip_funding_eligibility_state_data ||= {
      eligibility_blank: eligibility_blank?,
      teacher_profile_trn_present: teacher_profile_trn_present?,
      eligible: eligible?,
      ineligible: ineligible?,
      mentor: mentor?,
      manual_checks: manual_checks?,
      active_reason: active_reason?,
      ect: ect?,
    }
  end

  def mentor_fip_funding_eligibility_state_data
    @mentor_fip_funding_eligibility_state_data ||= {
      ineligible: ineligible?,
      mentor: mentor?,
      previous_participation_reason: previous_participation_reason?,
      secondary_profile: secondary_profile?,
      primary_profile: primary_profile?,
      duplicate_profile_reason: duplicate_profile_reason?,
    }
  end

  def ect_fip_funding_eligibility_state_data
    @ect_fip_funding_eligibility_state_data ||= {
      teacher_profile_trn_present: teacher_profile_trn_present?,
      ineligible: ineligible?,
      mentor: mentor?,
      manual_checks: manual_checks?,
      duplicate_profile_reason: duplicate_profile_reason?,
      no_induction_reason: no_induction_reason?,
      no_qts_reason: no_qts_reason?,
      exempt_from_induction_reason: exempt_from_induction_reason?,
      previous_induction_reason: previous_induction_reason?,
      validation_data_trn_present: validation_data_trn_present?,
    }
  end

  def training_state_data
    @training_state_data ||= {
      changed_training: changed_training?,
      leaving_school: leaving_school?,
      left_school: left_school?,
      joining_school: joining_school?,
      withdrawn_participant: withdrawn_participant?,
      withdrawn_training: withdrawn_training?,
      deferred_training: deferred_training?,
      completed_training: completed_training?,
    }
  end

  def ect_training_state_data
    @ect_training_state_data ||= {
      on_fip: on_fip?,
      on_cip: on_cip?,
      on_design_our_own: on_design_our_own?,
      partnership: partnership?,
      induction_start_date_in_past: induction_start_date_in_past?,
    }
  end

  def mentoring_state_data
    @mentoring_state_data ||= {
      mentor: mentor?,
      mentoring: mentoring?,
      previous_participation_reason: previous_participation_reason?,
    }
  end

  def record_state_data
    @record_state_data ||= {
      withdrawn_participant: withdrawn_participant?,
      transitioning_or_not_currently_training: transitioning_or_not_currently_training?,
      validation_status_valid: validation_status_valid?,
      eligible_for_training: eligible_for_training?,
      on_fip: on_fip?,
      application_funding_state: applicable_funding_state?,
      mentor: mentor?,
    }
  end

  def latest_request_for_details
    if induction_record.respond_to?(:transient_latest_request_for_details_status)
      return Email.new(status: induction_record.transient_latest_request_for_details_status)
    end

    @latest_request_for_details ||= Email
      .associated_with(participant_profile)
      .tagged_with(:request_for_details)
      .select(:status)
      .latest
  end

  def mentoring?
    return false unless mentor?
    return induction_record.transient_current_mentees if induction_record.respond_to?(:transient_current_mentees)

    @mentoring ||= InductionRecord.current.where(mentor_profile_id: participant_profile.id).exists?
  end

  def mentored?
    return false unless mentor?
    return induction_record.transient_mentees if induction_record.respond_to?(:transient_mentees)

    @mentored ||= InductionRecord.where(mentor_profile_id: participant_profile.id).exists?
  end

  def transitioning_or_not_currently_training?
    %i[
      withdrawn_training
      deferred_training
      completed_training
      joining
      leaving
      left
    ].include?(training_state)
  end

  def eligible_for_training?
    %i[
      eligible_for_mentor_training
      eligible_for_induction_training
    ].include?(training_eligibility_state)
  end

  def applicable_funding_state?
    %i[
      eligible_for_mentor_funding
      eligible_for_mentor_funding_primary
      eligible_for_fip_funding
      ineligible_secondary
      ineligible_ero
      ineligible_ero_primary
      ineligible_ero_secondary
    ].include?(fip_funding_eligibility_state)
  end

  def ect?
    participant_profile.ect?
  end

  def mentor?
    participant_profile.mentor?
  end

  def relevant_induction_programme
    @relevant_induction_programme ||= induction_record.induction_programme || participant_profile.school_cohort&.default_induction_programme
  end

  def on_fip?
    !!relevant_induction_programme&.full_induction_programme?
  end

  def on_cip?
    !!relevant_induction_programme&.core_induction_programme?
  end

  def on_design_our_own?
    !!relevant_induction_programme&.design_our_own?
  end

  def primary_profile?
    participant_profile.primary_profile?
  end

  def secondary_profile?
    participant_profile.secondary_profile?
  end

  def uplift?
    participant_profile.sparsity_uplift? || participant_profile.pupil_premium_uplift?
  end

  def awaiting_validation_data?
    participant_validation_data_blank? && !teacher_profile_trn_present?
  end

  def eligibility_blank?
    participant_profile.ecf_participant_eligibility.blank?
  end

  def eligible?
    !!participant_profile.ecf_participant_eligibility&.eligible_status?
  end

  def ineligible?
    !!participant_profile.ecf_participant_eligibility&.ineligible_status?
  end

  def manual_checks?
    !!participant_profile.ecf_participant_eligibility&.manual_check_status?
  end

  def exempt_from_induction_reason?
    !!participant_profile.ecf_participant_eligibility&.exempt_from_induction_reason?
  end

  def previous_induction_reason?
    !!participant_profile.ecf_participant_eligibility&.previous_induction_reason?
  end

  def previous_participation_reason?
    !!participant_profile.ecf_participant_eligibility&.previous_participation_reason?
  end

  def different_trn_reason?
    !!participant_profile.ecf_participant_eligibility&.different_trn_reason?
  end

  def duplicate_profile_reason?
    !!participant_profile.ecf_participant_eligibility&.duplicate_profile_reason?
  end

  def active_reason?
    !!participant_profile.ecf_participant_eligibility&.active_flags_reason?
  end

  def no_induction_reason?
    !!participant_profile.ecf_participant_eligibility&.no_induction_reason?
  end

  def no_qts_reason?
    !!participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def induction_start_date_in_past?
    !!participant_profile.induction_start_date&.past?
  end

  def teacher_profile_trn_present?
    participant_profile.teacher_profile&.trn.present?
  end

  def validation_data_api_failed?
    !!participant_profile.ecf_participant_validation_data&.api_failure
  end

  def validation_data_trn_present?
    participant_profile.ecf_participant_validation_data&.trn.present?
  end

  def participant_validation_data_blank?
    participant_profile.ecf_participant_validation_data.blank?
  end

  def latest_request_for_details_submitted?
    !!latest_request_for_details&.submitted?
  end

  def latest_request_for_details_failed?
    !!latest_request_for_details&.failed?
  end

  def latest_request_for_details_delivered?
    !!latest_request_for_details&.delivered?
  end

  def partnership?
    relevant_induction_programme&.partnership&.lead_provider.present?
  end

  def withdrawn_training?
    induction_record.training_status_withdrawn?
  end

  def deferred_training?
    induction_record.training_status_deferred?
  end

  def withdrawn_participant?
    induction_record.withdrawn_induction_status?
  end

  def completed_training?
    induction_record.completed_induction_status?
  end

  def changed_training?
    induction_record.changed_induction_status?
  end

  def leaving_school?
    induction_record.leaving_induction_status? && induction_record.end_date&.future?
  end

  def left_school?
    induction_record.leaving_induction_status? && induction_record.end_date&.past?
  end

  def joining_school?
    induction_record.active_induction_status? && induction_record.school_transfer && induction_record.start_date&.future?
  end
end
