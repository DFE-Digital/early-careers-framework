# frozen_string_literal: true

module Dashboard
  class Participants
    attr_reader :mentors, :orphan_ects, :school, :user

    def initialize(school:, user:)
      @orphan_ects = []
      @school = school
      @user = user
      @mentors = process_participants
    end

    def ects
      @ects ||= mentors.values.flatten.compact + orphan_ects
    end

    def no_qts
      @no_qts ||= induction_records.select { |induction_record| no_qts?(induction_record) }
    end

    def orphan_mentors
      @orphan_mentors ||= induction_records.select(&:mentor?) - mentors.keys
    end

    def dashboard_school_cohorts
      SchoolCohort.dashboard_for_school(school)
    end

  private

    # List of relevant (current or transferring_in or transferred) induction record of each of the participant of
    # the school in the cohorts displayed by the dashboard
    def induction_records
      @induction_records ||= dashboard_school_cohorts.flat_map do |school_cohort|
        InductionRecordPolicy::Scope.new(
          user,
          school_cohort
            .induction_records
            .current_or_transferring_in_or_transferred
            .eager_load(induction_programme: %i[school core_induction_programme lead_provider delivery_partner],
                        participant_profile: %i[user ecf_participant_eligibility ecf_participant_validation_data])
            .order("users.full_name"),
        ).resolve.to_a
      end
    end

    def induction_record_of_profile(profile_id)
      induction_records.detect do |induction_record|
        induction_record.participant_profile_id == profile_id
      end
    end

    def no_qts?(induction_record)
      !induction_record.training_status_withdrawn? &&
        (induction_record.active? || induction_record.claimed_by_another_school?) &&
        induction_record.enrolled_in_fip? &&
        induction_record.participant_manual_check_needed? &&
        induction_record.participant_no_qts?
    end

    def process_participants
      induction_records
        .select(&:ect?)
        .group_by(&:mentor_profile_id)
        .each_with_object({}) do |(mentor_profile_id, ects), hash|
        if mentor_profile_id
          hash[induction_record_of_profile(mentor_profile_id)] = ects
        else
          @orphan_ects = ects
        end
      end
    end
  end
end
