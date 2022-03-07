# frozen_string_literal: true

class CocSetParticipantCategories < BaseService
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
    if school_cohort.core_induction_programme?
      cip_participant_categories
    else
      fip_participant_categories
    end
  end

  def fip_participant_categories
    ParticipantCategories.new(eligible_participants, ineligible_participants, withdrawn_participants, contacted_for_info_participants, details_being_checked_participants, transferring_in_participants, transferring_out_participants)
  end

  def cip_participant_categories
    ParticipantCategories.new(cip_eligible_participants, [], withdrawn_participants, contacted_for_info_participants, [], transferring_in_participants, transferring_out_participants)
  end

  # def active_participant_profiles
  #   ParticipantProfilePolicy::Scope.new(user, school_cohort.active_ecf_participant_profiles.where(type: type)).resolve
  # end

  def participants
    @participants ||= ParticipantProfile::ECF
      .where(type: type)
      .includes(:user)
      .order("users.full_name")
  end

  def ineligible_participants
    participants
      .ineligible_status
      .where(id: active_induction_records.select(:participant_profile_id))
  end

  def eligible_participants
    participants
      .eligible_status
      .where(id: active_induction_records.select(:participant_profile_id))
  end

  def withdrawn_participants
    participants
      .where(id: withdrawn_induction_records.select(:participant_profile_id))
  end

  def contacted_for_info_participants
    participants
      .contacted_for_info
      .where(id: active_induction_records.select(:participant_profile_id))
  end

  def details_being_checked_participants
    participants
      .details_being_checked
      .where(id: active_induction_records.select(:participant_profile_id))
  end

  def transferring_in_participants
    participants
      .where(id: school_cohort.transferring_in_induction_records.select(:participant_profile_id))
  end

  def transferring_out_participants
    participants
      .where(id: school_cohort.transferring_out_induction_records.select(:participant_profile_id))
  end

  def active_induction_records
    school_cohort.active_induction_records.where.not(training_status: :withdrawn)
  end

  def withdrawn_induction_records
    school_cohort.current_induction_records.training_status_withdrawn
  end

  def incoming_induction_records
    school_cohort.transferring_in_induction_records
  end

  def cip_eligible_participants
    # find all the participants that have attempted to validate in any core_induction_programme
    # for the school_cohort
    participants
      .joins(:ecf_participant_validation_data)
      .where(id: active_induction_records
                  .joins(:induction_programme)
                  .where(induction_programme: { training_programme: :core_induction_programme })
                  .select(:participant_profile_id))
    # [*eligible_participants, *ineligible_participants, *details_being_checked_participants].uniq
  end
end
