# frozen_string_literal: true

module Dashboard
  class Participants
    attr_reader :mentors, :orphan_ects, :school, :user, :latest_year

    def initialize(school:, user:)
      @deferred_or_transferred_ects = []
      @latest_year = Dashboard::LatestManageableCohort.call(school).start_year
      @orphan_ects = []
      @school = school
      @user = user
      @mentors = process_participants
    end

    def dashboard_school_cohorts
      SchoolCohort.dashboard_for_school(school:, latest_year:)
    end

    def ects
      @ects ||= mentors.values.flatten.compact + orphan_ects
    end

    def ects_mentored_by(mentor)
      mentors[dashboard_mentor(mentor)]
    end

    def no_qts
      @no_qts ||= induction_records.select { |induction_record| no_qts?(induction_record) }
    end

    def not_mentoring_or_being_mentored
      @not_mentoring_or_being_mentored ||= (orphan_mentors + deferred_or_transferred_ects).sort_by(&:full_name)
    end

  private

    attr_reader :deferred_or_transferred_ects

    def dashboard_mentor(mentor)
      return mentor if mentor.is_a?(Dashboard::Participant)

      mentors.keys.detect { |dashboard_participant| dashboard_participant.participant_profile_id == mentor.id }
    end

    def dashboard_participants(induction_records)
      induction_records.map do |induction_record|
        dashboard_participant(induction_record.participant_profile_id, induction_record:)
      end
    end

    def dashboard_participant(participant_profile_id, induction_record: nil)
      induction_record ||= induction_records.detect { |ir| ir.participant_profile_id == participant_profile_id }

      Dashboard::Participant.new(induction_record:, participant_profile_id:)
    end

    # List of relevant (current or transferring_in or transferred) induction record of each of the participant of
    # the school in the cohorts displayed by the dashboard
    def induction_records
      @induction_records ||= dashboard_school_cohorts.flat_map do |school_cohort|
        InductionRecordPolicy::Scope
          .new(user,
               school_cohort
                 .induction_records
                 .current_or_transferring_in_or_transferred
                 .eager_load(induction_programme: %i[school core_induction_programme lead_provider delivery_partner],
                             participant_profile: %i[user ecf_participant_eligibility ecf_participant_validation_data])
                 .order("users.full_name"))
          .resolve
          .order(start_date: :desc, created_at: :desc)
          .uniq(&:participant_profile_id)
      end
    end

    def no_qts?(induction_record)
      !induction_record.training_status_withdrawn? &&
        (induction_record.active? || induction_record.claimed_by_another_school?) &&
        induction_record.enrolled_in_fip? &&
        induction_record.participant_manual_check_needed? &&
        induction_record.participant_no_qts?
    end

    def orphan_and_deferred_or_transferred_ects(ects)
      @deferred_or_transferred_ects, @orphan_ects = ects.partition(&:deferred_or_transferred?).map do |ects_subset|
        dashboard_participants(ects_subset)
      end
    end

    def orphan_mentors
      @orphan_mentors ||= school_mentors_not_mentoring.map do |school_mentor|
        dashboard_participant(school_mentor.participant_profile_id)
      end
    end

    def profile_ids_of_mentors_mentoring
      mentors.keys.map(&:participant_profile_id)
    end

    def process_participants
      induction_records
        .select(&:ect?)
        .group_by(&:mentor_profile_id)
        .each_with_object({}) do |(mentor_profile_id, ects), hash|
        if mentor_profile_id
          hash[dashboard_participant(mentor_profile_id)] = dashboard_participants(ects)
        else
          orphan_and_deferred_or_transferred_ects(ects)
        end
      end
    end

    def school_mentors_not_mentoring
      school.school_mentors.reject do |school_mentor|
        profile_ids_of_mentors_mentoring.include?(school_mentor.participant_profile_id)
      end
    end
  end
end
