# frozen_string_literal: true

module DataStage
  class ProcessSchoolChanges < ::BaseService
    include GiasTypes

    UNHANDLED_ATTRIBUTES = %w[
      administrative_district_code
      administrative_district_name
      school_type_code
      school_type_name
      section_41_approved
      ukprn
    ].freeze

    def call
      DataStage::SchoolChange.unhandled.status_changed.find_each do |change|
        next if has_unhandled_attributes?(change.attribute_changes)

        if change.attribute_changes.key? "school_status_code"
          handle_status_code_change(change)
        end
      end
    end

  private

    def has_unhandled_attributes?(attributes)
      (UNHANDLED_ATTRIBUTES & attributes.keys).any?
    end

    def handle_status_code_change(change)
      from_code = change.attribute_changes["school_status_code"]&.first
      to_code = change.attribute_changes["school_status_code"]&.last

      if open_status_code?(from_code) && !open_status_code?(to_code)
        close_school(change)
      elsif !open_status_code?(from_code) && open_status_code?(to_code)
        open_school(change)
      else
        # just sync then
        change.school.create_or_sync_counterpart!
      end
    end

    def open_school(change)
      school = change.school

      # is there a predecessor
      last_link = school.school_links.order(created_at: :asc).last

      if last_link.nil? || last_link.link_type == "Predecessor"
        DataStage::School.transaction do
          # no predecessor or simple predecessor - add new school
          school.create_or_sync_counterpart!

          # transfer assets if predecessor
          if last_link.present?
            predecessor = ::School.find_by(urn: last_link.link_urn)
            transfer_assets_from_predecessor(school: school.counterpart, predecessor: predecessor) if predecessor.present?
          end

          change.update!(handled: true)
        end
      end
    end

    def close_school(change)
      # let any related school open transfer any assets
      # just sync attribute changes
      DataStage::School.transaction do
        # only sync changes don't create
        change.school.create_or_sync_counterpart! if change.school.counterpart.present?
        change.update!(handled: true)
      end
    end

    def transfer_assets_from_predecessor(school:, predecessor:)
      # move everything to the new school
      Partnership.active.where(school: predecessor).each { |partnership| partnership.update!(school: school) }
      # TODO: What should we do here if the school already has a school_cohort (if anything)?
      if school.school_cohorts.empty?
        SchoolCohort.where(school: predecessor).each { |cohort| cohort.update!(school: school) }
      end

      TeacherProfile.where(school: predecessor).each { |profile| profile.update!(school: school) }
      InductionCoordinatorProfilesSchool.where(school: predecessor).each { |profile| profile.update!(school: school) }
    end
  end
end
