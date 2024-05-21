# frozen_string_literal: true

require "csv"

module Importers
  # This service reads a CSV containing a list of participant_profile_id for Mentors that need to be manually
  # set to "completed".  This is primarily where we are unable to confirm whether their training is complete but
  # it is expected that they have received sufficient training since they started that they do not need to
  # continue training. This is known internally as "Rule 3", where training has started but not completed.
  # This could also be used to bulk set mentor completions for other valid reasons
  # It is expected that this process will be required annually to assist with closing the cohort that is now 2 years old#
  #
  class ManualMentorCompletions < ::BaseService
    DEFAULT_COMPLETION_DATE = Date.new(2024, 7, 31)
    DEFAULT_COMPLETION_REASON = ParticipantProfile::Mentor.mentor_completion_reasons[:started_not_completed]

    def call
      check_completion_args!
      check_headers!

      rows.each do |row|
        set_mentor_completion!(row)
      rescue StandardError => e
        Rails.logger.error(e.message)
      end
    end

  private

    attr_reader :path_to_source_file, :completion_date, :completion_reason

    def initialize(path_to_source_file:, completion_date: DEFAULT_COMPLETION_DATE, completion_reason: DEFAULT_COMPLETION_REASON)
      @path_to_source_file = path_to_source_file
      @completion_date = completion_date
      @completion_reason = completion_reason
    end

    def set_mentor_completion!(row)
      id = row.fetch("participant_profile_id", nil)
      return if id.nil?

      participant_profile = ParticipantProfile::Mentor.find_by(id:)

      if participant_profile.nil?
        Rails.logger.warn "Cannot find mentor profile for id '#{id}'"
        return
      end

      if participant_profile.mentor_completion_date.present?
        Rails.logger.warn "Mentor completion already set for id '#{id}'"
        return
      end

      participant_profile.complete_training!(completion_date:, completion_reason:)
    end

    def check_completion_args!
      if completion_date.blank? || completion_date < DEFAULT_COMPLETION_DATE || completion_date > 1.year.from_now
        raise ArgumentError, "'#{completion_date}' is not a valid completion date"
      elsif completion_reason.blank? || ParticipantProfile::Mentor.mentor_completion_reasons.include?(completion_reason) == false
        raise ArgumentError, "'#{completion_reason}' is not a valid completion reason"
      end
    end

    def check_headers!
      raise NameError, "Cannot find expected column headers" unless rows.headers.include?("participant_profile_id")
    end

    def rows
      @rows ||= CSV.read(path_to_source_file, headers: true)
    end
  end
end
