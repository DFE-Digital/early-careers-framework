# frozen_string_literal: true

class SetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked, :transferring_in, :transferring_out)

  def call
    set_participant_categories
  end

private

  attr_reader :school_cohort, :user, :type

  def initialize(school_cohort, user, type)
    @school_cohort = school_cohort
    @user = user
    @type = type
  end

  def set_participant_categories
    if FeatureFlag.active?(:change_of_circumstances)
      if school_cohort.core_induction_programme?
        cip_participant_categories
      elsif FeatureFlag.active?(:eligibility_notifications)
        fip_participants_coc_feature_flag_active
      else
        fip_participant_categories_feature_flag_inactive
      end
    elsif school_cohort.core_induction_programme?
      cip_participant_categories
    elsif FeatureFlag.active?(:eligibility_notifications)
      fip_participant_categories_feature_flag_active
    else
      fip_participant_categories_feature_flag_inactive
    end
  end

  def fip_participant_categories_feature_flag_active
    ParticipantCategories.new(eligible_participants, fip_flag_active_ineligible_participants, fip_flag_active_withdrawn_participants, contacted_for_info_participants, details_being_checked_participants, [], [])
  end

  def fip_participant_categories_feature_flag_inactive
    ParticipantCategories.new([], [], withdrawn_participants, contacted_for_info_participants, fip_flag_inactive_details_being_checked_participants, [], [])
  end

  def cip_participant_categories
    ParticipantCategories.new(cip_eligible_participants, [], withdrawn_participants, contacted_for_info_participants, [], [], [])
  end

  def active_participant_profiles
    ParticipantProfilePolicy::Scope.new(user, school_cohort.active_ecf_participant_profiles.where(type: type)).resolve
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

  def fip_flag_active_ineligible_participants
    ineligible_participants - eligible_participants
  end

  def fip_flag_active_withdrawn_participants
    withdrawn_participants - [fip_flag_active_ineligible_participants, details_being_checked_participants].flatten
  end

  def cip_eligible_participants
    [*eligible_participants, *ineligible_participants, *details_being_checked_participants].uniq
  end

  def fip_flag_inactive_details_being_checked_participants
    [*details_being_checked_participants, *ineligible_participants, *eligible_participants].uniq
  end

  # change of circumstances feature flag methods

  def fip_participants_coc_feature_flag_active
    ParticipantCategories.new(coc_eligible_participants, coc_flag_active_ineligible, coc_withdrawn_participants, coc_contacted_for_info_participants, coc_details_being_checked_participants, coc_transferring_in, coc_transferring_out)
  end

  def coc_non_transferred
    profile_type = type.constantize
    ParticipantProfilePolicy::Scope.new(user, profile_type.where(id: coc_active_induction_records.select(:participant_profile_id)).includes(:user).order("users.full_name")).resolve
  end

  def coc_transferring_in
    ParticipantProfilePolicy::Scope.new(user, ParticipantProfile::ECF.where(id: school_cohort.transferring_in_induction_records.select(:participant_profile_id)).includes(:user).order("users.full_name")).resolve
  end

  def coc_transferring_out
    ParticipantProfilePolicy::Scope.new(user, ParticipantProfile::ECF.where(id: school_cohort.transferring_out_induction_records.select(:participant_profile_id)).includes(:user).order("users.full_name")).resolve
  end

  def coc_active_induction_records
    school_cohort.current_induction_records
  end

  def coc_eligible_participants
    coc_non_transferred.eligible_status.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def coc_ineligible_participants
    coc_non_transferred.ineligible_status.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def coc_withdrawn_participants
    coc_non_transferred.training_status_withdrawn.includes(:user).order("users.full_name")
  end

  def coc_contacted_for_info_participants
    coc_non_transferred.contacted_for_info.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def coc_details_being_checked_participants
    coc_non_transferred.details_being_checked.includes(:user).order("users.full_name").where.not(training_status: :withdrawn)
  end

  def coc_flag_active_ineligible
    coc_ineligible_participants - coc_eligible_participants
  end

  def coc_flag_active_withdrawn
    coc_ineligible_participants - [coc_flag_active_ineligible, coc_details_being_checked_participants].flatten
  end
end
