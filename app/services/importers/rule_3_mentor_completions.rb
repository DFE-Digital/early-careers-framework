# frozen_string_literal: true

require "csv"

module Importers
  class Rule3MentorCompletions < ::BaseService
    def call
      check_headers!

      rows.each do |row|
        set_mentor_completion!(row)
      rescue StandardError => e
        Rails.logger.error(e.message)
      end
    end

  private

    attr_reader :path_to_source_file, :completion_date

    def initialize(path_to_source_file:, completion_date: Date.new(2024, 7, 31))
      @path_to_source_file = path_to_source_file
      @completion_date = completion_date
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

    def completion_reason
      @completion_reason ||= ParticipantProfile::Mentor.mentor_completion_reasons[:started_not_completed]
    end

    def check_headers!
      raise NameError, "Cannot find expected column headers" unless rows.headers.include?("participant_profile_id")
    end

    def rows
      @rows ||= CSV.read(path_to_source_file, headers: true)
    end
  end
end
