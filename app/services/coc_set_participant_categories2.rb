# frozen_string_literal: true

class CocSetParticipantCategories2 < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked, :transferring_in, :transferring_out, :transferred, :no_qts_participants)

  # replace [] in call back to transferring_out_participants method once
  # transferring out journey is done
  # transferring out ppts are being shown in active_induction_records for now
  def call
    ParticipantCategories.new(
      eligible_participants,
      ineligible_participants,
      withdrawn_participants,
      contacted_for_info_participants,
      details_being_checked,
      transferring_in_participants,
      transferring_out_participants,
      transferred_participants,
      no_qts_participants,
    )
  end

private

  attr_reader :school_cohort, :user, :profile_type

  def initialize(school_cohort, user, profile_type)
    @school_cohort = school_cohort
    @user = user
    @profile_type = profile_type
  end

  def active_induction_records
    @active_induction_records ||= current_induction_records.select do |induction_record|
      !induction_record.training_status_withdrawn? &&
        (induction_record.active? || induction_record.claimed_by_another_school?)
    end
  end

  def cip_eligible_participants
    @cip_eligible_participants ||= active_induction_records.select do |induction_record|
      induction_record.enrolled_in_cip? &&
        induction_record.participant_profile.completed_validation_wizard?
    end
  end

  def contacted_for_info_participants
    @contacted_for_info_participants ||= active_induction_records.select do |induction_record|
      induction_record.participant_profile.contacted_for_info?
    end
  end

  def current_induction_records
    @current_induction_records ||= InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .induction_records
        .current_or_transferring_in_or_transferred
        .eager_load(induction_programme: %i[core_induction_programme lead_provider delivery_partner],
                    participant_profile: %i[user ecf_participant_eligibility ecf_participant_validation_data])
        .where(participant_profiles: { type: profile_type.to_s })
        .order("users.full_name"),
    ).resolve.to_a
  end

  def details_being_checked
    @details_being_checked ||= details_being_checked_participants - no_qts_participants
  end

  def details_being_checked_participants
    @details_being_checked_participants ||= active_induction_records.select do |induction_record|
      induction_record.enrolled_in_fip? &&
        induction_record.participant_profile.manual_check_needed?
    end
  end

  def eligible_participants
    fip_eligible_participants + cip_eligible_participants
  end

  def fip_eligible_participants
    @fip_eligible_participants ||= active_induction_records.select do |induction_record|
      induction_record.enrolled_in_fip? &&
        (induction_record.participant_profile.fundable? ||
          induction_record.participant_profile.ineligible_and_duplicated_or_previously_participated?)
    end
  end

  def ineligible_participants
    @ineligible_participants ||= active_induction_records.select do |induction_record|
      induction_record.enrolled_in_fip? &&
        induction_record.participant_profile.ineligible_but_not_duplicated_or_previously_participated?
    end
  end

  def no_qts_participants
    @no_qts_participants ||= details_being_checked_participants.select do |induction_record|
      induction_record.participant_profile.ecf_participant_eligibility&.no_qts_reason?
    end
  end

  def transferred_participants
    @transferred_participants ||= current_induction_records.select(&:transferred?)
  end

  def transferring_in_participants
    @transferring_in_participants ||= current_induction_records.select(&:transferring_in?)
  end

  def transferring_out_participants
    @transferring_out_participants ||= current_induction_records.select(&:transferring_out?)
  end

  def withdrawn_participants
    @withdrawn_participants ||= current_induction_records.select do |induction_record|
      induction_record.training_status_withdrawn? &&
        !induction_record.transferring_in? &&
        !induction_record.transferred?
    end
  end
end
