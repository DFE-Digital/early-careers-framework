# frozen_string_literal: true

class SetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked, :no_qts_participants)

  def call
    set_participant_categories
  end

private

  attr_reader :school_cohort, :user, :profile_type

  def initialize(school_cohort, user, profile_type)
    @school_cohort = school_cohort
    @user = user
    @profile_type = profile_type.to_s
  end

  def set_participant_categories
    if school_cohort.core_induction_programme?
      cip_participant_categories
    elsif FeatureFlag.active?(:eligibility_notifications)
      fip_participant_categories_feature_flag_active
    else
      fip_participant_categories_feature_flag_inactive
    end
  end

  def fip_participant_categories_feature_flag_active
    ParticipantCategories.new(eligible_participants, fip_flag_active_ineligible_participants, fip_flag_active_withdrawn_participants, contacted_for_info_participants, details_being_checked, no_qts_participants)
  end

  def fip_participant_categories_feature_flag_inactive
    ParticipantCategories.new([], [], withdrawn_participants, contacted_for_info_participants, fip_flag_inactive_details_being_checked_participants, [])
  end

  def cip_participant_categories
    ParticipantCategories.new(cip_eligible_participants, [], withdrawn_participants, contacted_for_info_participants, [], [])
  end

  def active_participant_profiles
    ParticipantProfilePolicy::Scope.new(user, school_cohort.active_ecf_participant_profiles.where(type: profile_type)).resolve
  end

  def ineligible_participants
    active_participant_profiles.ineligible_status.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def eligible_participants
    active_participant_profiles.eligible_status.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def withdrawn_participants
    active_participant_profiles.training_status_withdrawn.includes(:user).order("users.full_name")
  end

  def contacted_for_info_participants
    active_participant_profiles.contacted_for_info.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def details_being_checked_participants
    active_participant_profiles.details_being_checked.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def details_being_checked
    details_being_checked_participants - no_qts_participants
  end

  def no_qts_participants
    details_being_checked_participants.select(&:no_qts?)
  end

  def fip_flag_active_ineligible_participants
    ineligible_participants - eligible_participants
  end

  def fip_flag_active_withdrawn_participants
    withdrawn_participants - [fip_flag_active_ineligible_participants, details_being_checked_participants].flatten
  end

  def cip_eligible_participants
    [*eligible_participants, *ineligible_participants, *details_being_checked, *no_qts_participants].uniq
  end

  def fip_flag_inactive_details_being_checked_participants
    [*details_being_checked, *no_qts_participants, *ineligible_participants, *eligible_participants].uniq
  end
end
