# frozen_string_literal: true

module DataStage
  class SupportScripts
    attr_reader :logger

    def initialize(logger = Rails.logger)
      @logger = logger
    end

    def close_school_with_no_successor(urn:, leaving_date: Time.zone.now)
      ds = DataStage::School.find_by!(urn:)
      s = ds.counterpart

      ActiveRecord::Base.transaction do
        # mark anyone still at the school as having left
        s.school_cohorts.each do |school_cohort|
          school_cohort.induction_programmes.each do |induction_programme|
            induction_programme.induction_records.where(induction_status: %i[active completed]).find_each do |induction_record|
              induction_record.leaving!(leaving_date, transferring_out: true)
            end
          end
        end

        # remove induction coordinator(s) from the school (only removes the association with the school)
        s.induction_coordinator_profiles_schools.each(&:destroy!)

        # remove school mentors
        s.school_mentors.each(&:destroy!)

        # update school state
        ds.create_or_sync_counterpart!

        # mark school changes as done
        ds.school_changes.unprocessed.each do |school_change|
          school_change.update!(handled: true)
        end

        logger.info("Closed #{s.name_and_urn}")
      end
    end
  end
end
