# frozen_string_literal: true

class CocSetParticipantCategories < BaseService
  ParticipantCategories = Struct.new(
    :eligible,
    :contacted_for_info,
    :details_being_checked,
    :ineligible,
    :no_qts_participants,
    :transferred,
    :transferring_in,
    :transferring_out,
    :withdrawn,
  )

  def ect_categories
    @ect_categories ||= categories(ParticipantProfile::ECT.name)
  end

  def ineligible
    @ineligible ||= ect_categories.ineligible + mentor_categories.ineligible
  end

  def mentor_categories
    @mentor_categories ||= categories(ParticipantProfile::Mentor.name)
  end

  def transferred
    @transferred ||= ect_categories.transferred + mentor_categories.transferred
  end

  def transferring_in
    @transferring_in ||= ect_categories.transferring_in + mentor_categories.transferring_in
  end

  def transferring_out
    @transferring_out ||= ect_categories.transferring_out + mentor_categories.transferring_out
  end

  def withdrawn
    @withdrawn ||= ect_categories.withdrawn + mentor_categories.withdrawn
  end

private

  attr_reader :school_cohort, :user

  def initialize(school_cohort, user)
    @school_cohort = school_cohort
    @user = user
  end

  # Query methods
  def active_induction_records
    @active_induction_records ||= induction_records
                                    .select { |induction_record| active_induction_record?(induction_record) }
  end

  def categories(profile_type)
    ParticipantCategories.new(
      eligible_participants(profile_type),
      contacted_for_info_participants(profile_type),
      details_being_checked(profile_type),
      ineligible_participants(profile_type),
      no_qts_participants(profile_type),
      transferred_participants(profile_type),
      transferring_in_participants(profile_type),
      transferring_out_participants(profile_type),
      withdrawn_participants(profile_type),
    )
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

  # Retrieve the relevant induction record for each participant in the school cohort:
  # For participants transferring into the school cohort, get their transferring_in? induction_record.
  # For participants transferred from another school, get their transferred? induction_record
  # For the rest of participants, get their current induction record
  def induction_records
    @induction_records ||= InductionRecordPolicy::Scope.new(
      user,
      school_cohort
        .induction_records
        .current_or_transferring_in_or_transferred
        .eager_load(induction_programme: %i[school core_induction_programme lead_provider delivery_partner],
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
    @transferred_participants ||= induction_records
                                    .select(&:transferred?)
                                    .group_by(&:participant_type)

    Array(@transferred_participants[profile_type])
  end

  def transferring_in_participants(profile_type)
    @transferring_in_participants ||= induction_records
                                        .select(&:transferring_in?)
                                        .group_by(&:participant_type)

    Array(@transferring_in_participants[profile_type])
  end

  def transferring_out_participants(profile_type)
    @transferring_out_participants ||= induction_records
                                         .select(&:transferring_out?)
                                         .group_by(&:participant_type)

    Array(@transferring_out_participants[profile_type])
  end

  def withdrawn_participants(profile_type)
    @withdrawn_participants ||= induction_records
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
      induction_record.participant_completed_validation_wizard?
  end

  def contacted_for_info_participant?(induction_record)
    induction_record.participant_contacted_for_info?
  end

  def details_being_checked_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      induction_record.participant_manual_check_needed?
  end

  def fip_eligible_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      (induction_record.participant_fundable? ||
        induction_record.participant_ineligible_and_duplicated_or_previously_participated?)
  end

  def ineligible_participant?(induction_record)
    induction_record.enrolled_in_fip? &&
      induction_record.participant_ineligible_but_not_duplicated_or_previously_participated?
  end

  def no_qts_participant?(induction_record)
    induction_record.participant_no_qts?
  end

  def withdrawn_participant?(induction_record)
    induction_record.training_status_withdrawn? &&
      !induction_record.transferring_in? &&
      !induction_record.transferred?
  end
end
