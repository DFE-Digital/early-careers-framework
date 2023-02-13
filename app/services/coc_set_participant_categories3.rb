# frozen_string_literal: true

class CocSetParticipantCategories3 < BaseService
  ParticipantCategories = Struct.new(:eligible, :ineligible, :withdrawn, :contacted_for_info, :details_being_checked, :transferring_in, :transferring_out, :transferred, :no_qts_participants)

  ECT = ParticipantProfile::ECT.name
  MENTOR = ParticipantProfile::Mentor.name

  # replace [] in call back to transferring_out_participants method once
  # transferring out journey is done
  # transferring out ppts are being shown in active_induction_records for now
  def call
    [MENTOR, ECT].map do |profile_type|
      ParticipantCategories.new(eligible_participants(profile_type),
                                ineligible_participants(profile_type),
                                withdrawn_participants(profile_type),
                                contacted_for_info_participants(profile_type),
                                details_being_checked(profile_type),
                                transferring_in_participants(profile_type),
                                transferring_out_participants(profile_type),
                                transferred_participants(profile_type),
                                no_qts_participants(profile_type))
    end
  end

private

  attr_reader :school_cohort, :user

  def initialize(school_cohort, user)
    @school_cohort = school_cohort
    @user = user
  end

  # Query methods
  def active_induction_records
    @active_induction_records ||= current_induction_records
                                    .select { |induction_record| active_induction_record?(induction_record) }
  end

  def cip_eligible_participants(profile_type)
    @cip_eligible_participants ||= active_induction_records
                                     .select { |induction_record| cip_eligible_participant?(induction_record) }
                                     .group_by(&:participant_type)

    Array(@cip_eligible_participants[profile_type])
  end

  def contacted_for_info_participants(profile_type)
    @contacted_for_info_participants ||= active_induction_records
                                           .select { |induction_record| contacted_for_info_participant?(induction_record) }
                                           .group_by(&:participant_type)

    Array(@contacted_for_info_participants[profile_type])
  end

  def current_induction_records
    @current_induction_records ||= InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .induction_records
        .current_or_transferring_in_or_transferred
        .eager_load(induction_programme: %i[core_induction_programme lead_provider delivery_partner],
                    participant_profile: %i[user ecf_participant_eligibility ecf_participant_validation_data])
        .order("users.full_name"),
    ).resolve.to_a
  end

  def details_being_checked(profile_type)
    details_being_checked_participants(profile_type) - no_qts_participants(profile_type)
  end

  def details_being_checked_participants(profile_type = nil)
    @details_being_checked_participants ||= active_induction_records
                                              .select { |induction_record| details_being_checked_participant?(induction_record) }
                                              .group_by(&:participant_type)

    if profile_type
      Array(@details_being_checked_participants[profile_type])
    else
      @details_being_checked_participants.values.flatten
    end
  end

  def eligible_participants(profile_type)
    (fip_eligible_participants(profile_type) + cip_eligible_participants(profile_type))
      .sort_by(&:participant_full_name)
  end

  def fip_eligible_participants(profile_type)
    @fip_eligible_participants ||= active_induction_records
                                     .select { |induction_record| fip_eligible_participant?(induction_record) }
                                     .group_by(&:participant_type)

    Array(@fip_eligible_participants[profile_type])
  end

  def ineligible_participants(profile_type)
    @ineligible_participants ||= active_induction_records
                                   .select { |induction_record| ineligible_participant?(induction_record) }
                                   .group_by(&:participant_type)

    Array(@ineligible_participants[profile_type])
  end

  def no_qts_participants(profile_type)
    @no_qts_participants ||= details_being_checked_participants
                               .select { |induction_record| no_qts_participant?(induction_record) }
                               .group_by(&:participant_type)

    Array(@no_qts_participants[profile_type])
  end

  def transferred_participants(profile_type)
    @transferred_participants ||= current_induction_records
                                    .select(&:transferred?)
                                    .group_by(&:participant_type)

    Array(@transferred_participants[profile_type])
  end

  def transferring_in_participants(profile_type)
    @transferring_in_participants ||= current_induction_records
                                        .select(&:transferring_in?)
                                        .group_by(&:participant_type)

    Array(@transferring_in_participants[profile_type])
  end

  def transferring_out_participants(profile_type)
    @transferring_out_participants ||= current_induction_records
                                         .select(&:transferring_out?)
                                         .group_by(&:participant_type)

    Array(@transferring_out_participants[profile_type])
  end

  def withdrawn_participants(profile_type)
    @withdrawn_participants ||= current_induction_records
                                  .select { |induction_record| withdrawn_participant?(induction_record) }
                                  .group_by(&:participant_type)

    Array(@withdrawn_participants[profile_type])
  end

  # Type check methods
  def active_induction_record?(induction_record)
    !induction_record.training_status_withdrawn? &&
      (induction_record.active? || induction_record.claimed_by_another_school?)
  end

  def cip_eligible_participant?(induction_record)
    induction_record.enrolled_in_cip? &&
      induction_record.participant_profile.completed_validation_wizard?
  end

  def contacted_for_info_participant?(induction_record)
    induction_record.participant_profile.contacted_for_info?
  end

  def details_being_checked_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      induction_record.participant_profile.manual_check_needed?
  end

  def fip_eligible_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      (induction_record.participant_profile.fundable? ||
        induction_record.participant_profile.ineligible_and_duplicated_or_previously_participated?)
  end

  def ineligible_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      induction_record.participant_profile.ineligible_but_not_duplicated_or_previously_participated?
  end

  def no_qts_participant?(induction_record)
    induction_record.participant_profile.ecf_participant_eligibility&.no_qts_reason?
  end

  def withdrawn_participant?(induction_record)
    induction_record.training_status_withdrawn? &&
      !induction_record.transferring_in? &&
      !induction_record.transferred?
  end
end
