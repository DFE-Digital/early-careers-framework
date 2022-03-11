# frozen_string_literal: true

class CocSetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked, :transferring_in, :transferring_out, :transferred)

  def call
    ParticipantCategories.new(
      eligible_participants,
      ineligible_participants,
      withdrawn_participants,
      contacted_for_info_participants,
      details_being_checked_participants,
      transferring_in_participants,
      transferring_out_participants,
      transferred_participants,
    )
  end

private

  attr_reader :school_cohort, :user, :type, :profile_class

  def initialize(school_cohort, user, type)
    @school_cohort = school_cohort
    @user = user
    @type = type
    @profile_class = type.constantize
  end

  def ineligible_participants
    active_induction_records
      .fip
      .merge(profile_class.ineligible_status)
  end

  def eligible_participants
    fip_eligible_participants + cip_eligible_participants
  end

  def withdrawn_participants
    withdrawn_induction_records
  end

  def contacted_for_info_participants
    active_induction_records
      .merge(profile_class.contacted_for_info)
  end

  def details_being_checked_participants
    active_induction_records
      .fip
      .merge(profile_class.details_being_checked)
  end

  def transferring_in_participants
    school_cohort
      .transferring_in_induction_records
      .joins(:participant_profile)
      .where(participant_profiles: { type: type })
      .includes(:user)
      .order("users.full_name")
  end

  def transferring_out_participants
    school_cohort
      .transferring_out_induction_records
      .joins(:participant_profile)
      .where(participant_profiles: { type: type })
      .includes(:user)
      .order("users.full_name")
  end

  def transferred_participants
    school_cohort
      .transferred_induction_records
      .joins(:participant_profile)
      .where(participant_profiles: { type: type })
      .includes(:user)
      .order("users.full_name")
  end

  def active_induction_records
    school_cohort
      .active_induction_records
      .where.not(training_status: :withdrawn)
      .joins(:participant_profile)
      .where(participant_profiles: { type: type })
      .includes(:user)
      .order("users.full_name")
  end

  def withdrawn_induction_records
    school_cohort
      .current_induction_records
      .training_status_withdrawn
      .joins(:participant_profile)
      .where(participant_profiles: { type: type })
      .includes(:user)
      .order("users.full_name")
  end

  def incoming_induction_records
    school_cohort.transferring_in_induction_records
  end

  def fip_eligible_participants
    active_induction_records
      .fip
      .merge(profile_class.eligible_status)
  end

  def cip_eligible_participants
    # find all the participants that have attempted to validate in any core_induction_programme
    # for the school_cohort
    active_induction_records
      .joins(participant_profile: :ecf_participant_validation_data)
      .cip
  end
end
