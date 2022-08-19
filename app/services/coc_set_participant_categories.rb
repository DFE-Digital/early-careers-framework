# frozen_string_literal: true

class CocSetParticipantCategories < BaseService
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

  def eligible_participants
    fip_eligible_participants + cip_eligible_participants + sffip_eligible_participants
  end

  def ineligible_participants
    fip_ineligible_participants + sffip_ineligible_participants
  end

  def withdrawn_participants
    withdrawn_induction_records
  end

  def contacted_for_info_participants
    active_induction_records
      .merge(profile_type.contacted_for_info)
  end

  def details_being_checked_participants
    fip_details_being_checked_participants + sffip_details_being_checked_participants
  end

  def details_being_checked
    details_being_checked_participants - no_qts_participants
  end

  def no_qts_participants
    details_being_checked_participants.select { |record| record.participant_profile.ecf_participant_eligibility&.no_qts_reason? }
  end

  def transferring_in_participants
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .transferring_in_induction_records
        .joins(:participant_profile)
        .where(participant_profiles: { type: profile_type.to_s })
        .includes(:user)
        .order("users.full_name"),
    ).resolve
  end

  def transferring_out_participants
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .transferring_out_induction_records
        .joins(:participant_profile)
        .where(participant_profiles: { type: profile_type.to_s })
        .includes(:user)
        .order("users.full_name"),
    ).resolve
  end

  def transferred_participants
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .transferred_induction_records
        .joins(:participant_profile)
        .where(participant_profiles: { type: profile_type.to_s })
        .includes(:user)
        .order("users.full_name"),
    ).resolve
  end

  # switch back to active_induction_records once transferring out journey is done
  # Until this is done we want to show the active and transferring_out in this section
  def active_induction_records
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .current_induction_records
        .where.not(training_status: :withdrawn)
        .joins(:participant_profile)
        .where(participant_profiles: { type: profile_type.to_s })
        .includes(:user)
        .order("users.full_name"),
    ).resolve
  end

  def withdrawn_induction_records
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .current_induction_records
        .training_status_withdrawn
        .joins(:participant_profile)
        .where(participant_profiles: { type: profile_type.to_s })
        .includes(:user)
        .order("users.full_name"),
    ).resolve
  end

  def incoming_induction_records
    InductionRecordPolicy::Scope.new(
      user,
      school_cohort.transferring_in_induction_records,
    ).resolve
  end

  def cip_eligible_participants
    # find all the participants that have attempted to validate in any core_induction_programme
    # for the school_cohort
    active_induction_records
      .joins(participant_profile: :ecf_participant_validation_data)
      .cip
  end

  def fip_details_being_checked_participants
    active_induction_records
      .fip
      .merge(profile_type.details_being_checked)
  end

  def fip_eligible_participants
    active_induction_records
      .fip
      .merge(profile_type.eligible_status)
  end

  def fip_ineligible_participants
    active_induction_records
      .fip
      .merge(profile_type.ineligible_status)
  end

  def sffip_details_being_checked_participants
    active_induction_records
      .sffip
      .merge(profile_type.details_being_checked)
  end

  def sffip_eligible_participants
    active_induction_records
      .sffip
      .merge(profile_type.eligible_status)
  end

  def sffip_ineligible_participants
    active_induction_records
      .sffip
      .merge(profile_type.ineligible_status)
  end
end
