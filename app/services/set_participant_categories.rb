# frozen_string_literal: true

class SetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :contacted_for_info, :details_being_checked)

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
    ParticipantCategories.new(eligible_participants, fip_flag_active_ineligible_participants, contacted_for_info_participants, details_being_checked_participants)
  end

  def fip_participant_categories_feature_flag_inactive
    ParticipantCategories.new([], [], contacted_for_info_participants, fip_flag_inactive_details_being_checked_participants)
  end

  def cip_participant_categories
    ParticipantCategories.new(cip_eligible_participants, [], contacted_for_info_participants, [])
  end

  def active_participant_profiles
    ParticipantProfilePolicy::Scope.new(user, ParticipantProfile::ECF.active_record)
      .resolve
      .where(school_cohort: school_cohort)
  end

  def ineligible_participants
    active_participant_profiles.ineligible_status.includes(:user).order("users.full_name")
  end

  def eligible_participants
    active_participant_profiles.eligible_status.includes(:user).order("users.full_name")
  end

  def contacted_for_info_participants
    active_participant_profiles.contacted_for_info.includes(:user).order("users.full_name")
  end

  def details_being_checked_participants
    active_participant_profiles.details_being_checked.includes(:user).order("users.full_name")
  end

  def fip_flag_active_ineligible_participants
    ineligible_participants - eligible_participants
  end

  def cip_eligible_participants
    [*eligible_participants, *ineligible_participants, *details_being_checked_participants].uniq
  end

  def fip_flag_inactive_details_being_checked_participants
    [*details_being_checked_participants, *ineligible_participants, *eligible_participants].uniq
  end
end
