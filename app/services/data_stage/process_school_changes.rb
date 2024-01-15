# frozen_string_literal: true

module DataStage
  class ProcessSchoolChanges < ::BaseService
    include GiasTypes

    def call
      DataStage::SchoolChange.includes(:school).unprocessed.status_changed.find_each do |change|
        if change.attribute_changes.key? "school_status_code"
          handle_status_code_change(change)
        else
          change.school.create_or_sync_counterpart!
        end
      end
    end

  private

    def handle_status_code_change(change)
      from_code = change.school.school_status_code

      if from_code.in? CLOSED_STATUS_CODES
        close_school(change)
      else
        open_or_sync_school(change)
      end
    end

    def open_or_sync_school(change)
      # simple opening/sync of school
      ActiveRecord::Base.transaction do
        change.school.create_or_sync_counterpart!
        change.update!(handled: true)
      end
    end

    def close_school(change)
      # if the live school doesn't exist there is no need to create it just to mark it as closed
      if change.school.counterpart.blank?
        change.update!(handled: true)
        return
      end

      ActiveRecord::Base.transaction do
        successor_link = change.school.school_links.find_by(link_type: "Successor")
        # only handle simple "Successor" cases here not mergers and splits etc.
        if successor_link.present?
          successor = find_or_create_successor!(successor_link.link_urn)
          move_assets_from!(school: change.school.counterpart, successor:)
          change.school.counterpart.school_links.successor.simple.create!(link_urn: successor.urn)
          successor.school_links.predecessor.simple.create!(link_urn: change.school.urn)
          change.school.create_or_sync_counterpart!
          change.update!(handled: true)
        elsif change.school.school_links.none?
          # when there are no school_links, check if we can just close this school?
          live_school = change.school.counterpart
          if live_school.present?
            if live_school.school_cohorts.none? && live_school.induction_coordinators.none?
              change.school.create_or_sync_counterpart!
              change.update!(handled: true)
            end
          else
            change.update!(handled: true)
          end
        end
      end
    end

    def find_or_create_successor!(urn)
      school = DataStage::School.find_by!(urn:)
      school.create_or_sync_counterpart!
      school.counterpart
    end

    def move_assets_from!(school:, successor:)
      raise ActiveRecord::Rollback if successor.school_cohorts.any?

      Partnership.active.where(school:).find_each { |partnership| partnership.update!(school: successor) }

      SchoolCohort.where(school:).find_each do |school_cohort|
        school_cohort.update!(school: successor)
        school_cohort.ecf_participant_profiles.each do |profile|
          RectifyParticipantSchool.call(participant_profile: profile,
                                        from_school: school,
                                        to_school: successor,
                                        transfer_pupil_premium_and_sparsity: false)
        end
      end

      InductionCoordinatorProfilesSchool.where(school:).find_each { |link_record| link_record.update!(school: successor) }
    end
  end
end
