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

        # update school state and mark school changes as done
        sync_and_handle_changes(staged_school)

        logger.info("Closed #{live_school.name_and_urn}")
      end
    end

    def migrate_school_to_successor(closing_urn:, successor_urn:)
      closing_staged_school = DataStage::School.find_by!(urn: closing_urn)
      closing_school = closing_staged_school.counterpart
      successor_staged_school = DataStage::School.find_by!(urn: successor_urn)
      successor_school = successor_staged_school.counterpart

      ActiveRecord::Base.transaction do
        closing_school.school_cohorts.each do |closing_cohort|
          next if closing_cohort.induction_records.none?

          successor_cohort = successor_school.school_cohorts.find_by(cohort: closing_cohort.cohort)

          if successor_cohort.blank?
            # we can just move the whole cohort over
            closing_cohort.update!(school: successor_school)
          else
            # we need to be more surgical and move programmes or participants individually
            closing_cohort.induction_programmes.each do |closing_programme|
              next if closing_programme.induction_records.none?

              # someone is recorded here
              move_to_matching_programme_or_move_this_one(closing_programme, successor_cohort)
            end
          end
        end

        if successor_school.induction_coordinators.none?
          sit_school_link = closing_school.induction_coordinator_profiles_schools.first
          sit_school_link.update!(school: successor_school) if sit_school_link.present?
        else
          closing_school.induction_coordinator_profiles_schools.each(&:destroy!)
        end

        # move school mentors (only school_mentor records not the participant_profiles)
        move_or_remove_school_mentors(closing_school, successor_school)

        # update school state and mark school changes as done
        sync_and_handle_changes(closing_staged_school)
      end

      logger.info("Migrated #{closing_school.name_and_urn} to #{successor_school.name_and_urn}")
    end

  private

    def sync_and_handle_changes(staged_school)
      # update school state
      staged_school.create_or_sync_counterpart!

      # mark school changes as done
      staged_school.school_changes.unprocessed.each do |school_change|
        school_change.update!(handled: true)
      end
    end

    def move_or_remove_school_mentors(from_school, to_school)
      from_school.school_mentors.each do |school_mentor|
        if to_school.school_mentors.find_by(participant_profile: school_mentor.participant_profile).present?
          school_mentor.destroy!
        else
          school_mentor.update!(school: to_school)
        end
      end
    end

    def move_or_relink_partnership(induction_programme)
      partnership = induction_programme.partnership
      return if partnership.blank?

      # programme has already been moved to the new school
      new_school = induction_programme.school_cohort.school
      existing_partnership = new_school.partnerships.where(cohort: partnership.cohort,
                                                           lead_provider: partnership.lead_provider,
                                                           delivery_partner: partnership.delivery_partner).first
      if existing_partnership.present?
        induction_programme.update!(partnership: existing_partnership)
      else
        partnership.update!(school: new_school)
      end
    end

    def move_to_matching_programme_or_move_this_one(induction_programme, school_cohort)
      matching_programme = nil
      school_cohort.induction_programmes.each do |prog|
        next if matching_programme.present?

        matching_programme = prog if programmes_match?(induction_programme, prog)
      end

      if matching_programme.present?
        # move contents of induction programme to matching one
        induction_programme.induction_records.find_each do |induction_record|
          induction_record.update!(induction_programme: matching_programme)
          induction_record.participant_profile.update!(school_cohort:) if induction_record.induction_status.in? %w[active completed]
        end
      else
        # move induction programme to school_cohort
        induction_programme.induction_records.where(induction_status: %i[active completed]).find_each do |induction_record|
          induction_record.participant_profile.update!(school_cohort:)
        end
        induction_programme.update!(school_cohort:)
        move_or_relink_partnership(induction_programme)
      end
    end

    def programmes_match?(prog1, prog2)
      return false if prog1.training_programme != prog2.training_programme

      if prog1.full_induction_programme?
        partnership1 = prog1.partnership
        partnership2 = prog2.partnership

        return true if partnership1.nil? && partnership2.nil?
        return false if partnership1.nil? || partnership2.nil?

        partnership1.lead_provider_id == partnership2.lead_provider_id && partnership1.delivery_partner_id == partnership2.delivery_partner_id
      elsif prog1.core_induction_programme?
        prog1.core_induction_programme_id == prog2.core_induction_programme_id
      else
        true
      end
    end
  end
end
