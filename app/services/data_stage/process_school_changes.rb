# frozen_string_literal: true

module DataStage
  class ProcessSchoolChanges < ::BaseService
    include GiasTypes

    UNHANDLED_ATTRIBUTES = %w[
      school_type_code
      school_type_name
      section_41_approved
      ukprn
    ].freeze

    def call
      DataStage::SchoolChange.includes(:school).unhandled.status_changed.find_each do |change|
        next if has_unhandled_changes?(change)

        if change.attribute_changes.key? "school_status_code"
          handle_status_code_change(change)
        else
          change.school.create_or_sync_counterpart!
        end
      end
    end

  private

    def has_unhandled_changes?(school_change)
      unhandled_attrs = (unhandled_attributes & school_change.attribute_changes.keys)
      school = school_change.school
      counterpart = school.counterpart

      has_unhandled_changes = false

      if counterpart.present? && unhandled_attrs.any?
        unhandled_attrs.each do |attr|
          current_value = counterpart.send(attr)
          next if current_value.blank? || current_value == school.send(attr)
          has_unhandled_changes = true
          break
        end
      end

      has_unhandled_changes
    end

    def has_unhandled_attributes?(attributes)
      (unhandled_attributes & attributes.keys).any?
    end

    def unhandled_attributes
      MAJOR_CHANGE_ATTRIBUTES - %w[school_status_code school_status_name]
    end

    def handle_status_code_change(change)
      from_code = change.school.school_status_code

      if from_code.in? [1, 3]
        # open status codes
        open_school(change)
      elsif from_code.in? [2, 4]
        # closed statuses
        close_school(change)
      end
    end

    def open_school(change)
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
        if successor_link.present?
          successor = find_or_create_successor!(successor_link.link_urn)
          move_assets_from!(school: change.school.counterpart, successor: successor)
          change.school.counterpart.school_links.successor.simple.create!(link_urn: successor.urn)
          successor.school_links.predecessor.simple.create!(link_urn: change.school.urn)
        end
        change.school.create_or_sync_counterpart!
        change.update!(handled: true)
      end
    end

    def find_or_create_successor!(urn)
      school = DataStage::School.find_by!(urn: urn)
      school.create_or_sync_counterpart!
      school.counterpart
    end

    def move_assets_from!(school:, successor:)
      raise ActiveRecord::Rollback if successor.school_cohorts.any?

      Partnership.active.where(school: school).each { |partnership| partnership.update!(school: successor) }

      SchoolCohort.where(school: school).each do |school_cohort|
        school_cohort.update!(school: successor)
        school_cohort.ecf_participant_profiles.each do |profile|
          RectifyParticipantSchool.call(participant_profile: profile, school: successor)
        end
      end

      InductionCoordinatorProfilesSchool.where(school: school).each { |profile| profile.update!(school: successor) }
    end
  end
end
