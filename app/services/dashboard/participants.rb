# frozen_string_literal: true

module Dashboard
  class Participants
    attr_reader :completed_induction, :mentors, :orphan_ects, :school, :user, :latest_year, :active_mentors

    def initialize(school:, user:)
      @active_mentors = []
      @completed_induction = []
      @currently_training_ects = []
      @no_longer_training_ects = []
      @no_longer_training_mentors = []
      @latest_year = Dashboard::LatestManageableCohort.call(school).start_year
      @orphan_ects = []
      @school = school
      @user = user

      process_participants
    end

    def completed_induction_count
      completed_induction.size
    end

    def currently_training_count
      (currently_training_ects + orphan_ects + active_mentors).size
    end

    def no_longer_training_count
      no_longer_training.size
    end

    def dashboard_school_cohorts
      SchoolCohort.dashboard_for_school(school:, latest_year:)
    end

    def ects
      @ects ||= sorted_ects
    end

    def ects_mentored_by(mentor)
      mentors[dashboard_mentor(mentor)]
    end

    def no_qts
      @no_qts ||= induction_records.select { |induction_record| no_qts?(induction_record) }
    end

    def no_longer_training
      @no_longer_training ||= (no_longer_training_mentors + no_longer_training_ects).sort_by(&:full_name)
    end

  private

    attr_reader :currently_training_ects, :no_longer_training_ects, :no_longer_training_mentors

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
                 .school_dashboard_relevant
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

    def completed_induction_ect(induction_record)
      @completed_induction << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def currently_training_ect(induction_record)
      @currently_training_ects << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def no_longer_training_ect(induction_record)
      @no_longer_training_ects << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def withdrawn_ect(induction_record)
      @withdrawn_ects << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def orphan_ect(induction_record)
      @orphan_ects << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def no_longer_training_mentor(induction_record)
      @no_longer_training_mentors << dashboard_participant(induction_record.participant_profile_id, induction_record:)
    end

    def process_participants
      process_ects
      process_mentors
    end

    def process_ects
      induction_records
        .select(&:ect?)
        .each do |induction_record|
          next completed_induction_ect(induction_record) if induction_record.completed_induction_status?
          next no_longer_training_ect(induction_record) if induction_record.deferred_or_transferred? || induction_record.withdrawn_induction_status?
          next orphan_ect(induction_record) if induction_record.mentor_profile_id.blank?

          currently_training_ect(induction_record)
        end
    end

    # Discover all the relevant mentors of the school, including:
    # - orphan mentors
    # - mentors with mentees
    # - mentors linked to the school's ects, but not in the school's mentor pool
    def process_mentors
      induction_records
        .reject(&:ect?)
        .each do |induction_record|
          next no_longer_training_mentor(induction_record) if induction_record.deferred_or_transferred? || induction_record.withdrawn_induction_status?

          @active_mentors << dashboard_participant(induction_record.participant_profile_id, induction_record:)
        end

      # Create a hash with the format below, to display the mentors in the "Currently training" filter
      # { mentor_dashboard_participant => [ect_dashboard_participant_1, ect_dashboard_participant_2] }
      @mentors = @currently_training_ects.group_by(&:mentor_profile_id).transform_keys do |mentor_profile_id|
        dashboard_participant(mentor_profile_id)
      end

      # Include also the orphan mentors in the @mentors
      orphan_mentor_ids = @active_mentors.map(&:participant_profile_id) - @currently_training_ects.map(&:mentor_profile_id)
      orphan_mentor_ids.each do |mentor_profile_id|
        @mentors[dashboard_participant(mentor_profile_id)] = nil
      end
    end

    def sorted_ects
      ects = (currently_training_ects + orphan_ects).sort_by do |ect|
        [ect.induction_start_date || Float::INFINITY, ect.full_name]
      end

      ects.reverse
    end
  end
end
