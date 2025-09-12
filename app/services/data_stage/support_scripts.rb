# frozen_string_literal: true

module DataStage
  class SupportScripts
    attr_reader :logger

    def initialize(logger = Rails.logger)
      @logger = logger
    end

    def close_school_with_no_successor(urn:, leaving_date: Time.zone.now)
      staged_school = DataStage::School.find_by!(urn:)
      live_school = staged_school.counterpart

      ActiveRecord::Base.transaction do
        # mark anyone still at the school as having left
        live_school.school_cohorts.each do |school_cohort|
          school_cohort.induction_programmes.each do |induction_programme|
            induction_programme.induction_records.where(induction_status: %i[active completed]).find_each do |induction_record|
              induction_record.leaving!(leaving_date, transferring_out: true)
            end
          end
        end

        # remove induction coordinator(s) from the school (only removes the association with the school)
        live_school.induction_coordinator_profiles_schools.each(&:destroy!)

        # remove school mentors (only school_mentor records not the participant_profiles)
        live_school.school_mentors.each(&:destroy!)

        # update school state
        staged_school.create_or_sync_counterpart!

        # mark school changes as done
        staged_school.school_changes.unprocessed.each do |school_change|
          school_change.update!(handled: true)
        end

        logger.info("Closed #{live_school.name_and_urn}")
      end
    end
  end
end
