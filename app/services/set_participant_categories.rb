# frozen_string_literal: true

class SetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked)

  def call
    set_participant_categories
  end

private

  attr_reader :school_cohort, :user

  def initialize(school_cohort, user)
    @school_cohort = school_cohort
    @user = user
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
    ParticipantCategories.new(eligible_participants, fip_flag_active_ineligible_participants, fip_flag_active_withdrawn_participants, contacted_for_info_participants, details_being_checked_participants)
  end

  def fip_participant_categories_feature_flag_inactive
    ParticipantCategories.new([], [], withdrawn_participants, contacted_for_info_participants, fip_flag_inactive_details_being_checked_participants)
  end

  def cip_participant_categories
    ParticipantCategories.new(cip_eligible_participants, [], contacted_for_info_participants, [])
  end

  def active_participant_profiles
    ParticipantProfilePolicy::Scope.new(user, school_cohort.active_ecf_participant_profiles).resolve
  end

  def ineligible_participants
    active_participant_profiles.ineligible_status.includes(:user).order("users.full_name")
  end

  def eligible_participants
    active_participant_profiles.eligible_status.includes(:user).order("users.full_name")
  end

  def withdrawn_participants
    active_participant_profiles.training_status_withdrawn.includes(:user).order("users.full_name")
  end

  def contacted_for_info_participants
    contacted_for_info = active_participant_profiles.contacted_for_info.includes(:user).order("users.full_name")
    contacted_for_info - withdrawn_participants
  end

  def details_being_checked_participants
    active_participant_profiles.details_being_checked.includes(:user).order("users.full_name")
  end

  def fip_flag_active_ineligible_participants
    ineligible_participants - eligible_participants
  end

  def fip_flag_active_withdrawn_participants
    withdrawn_participants - fip_flag_active_ineligible_participants
  end

  def cip_eligible_participants
    [*eligible_participants, *ineligible_participants, *withdrawn_participants, *details_being_checked_participants].uniq
  end

  def fip_flag_inactive_details_being_checked_participants
    [*details_being_checked_participants, *ineligible_participants, *eligible_participants, *withdrawn_participants].uniq
  end
end
