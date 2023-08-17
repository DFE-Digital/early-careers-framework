# frozen_string_literal: true

require "csv"

module Importers
  class CreateNPQCourse < BaseService
    def call
      check_headers!

      logger.info "CreateNPQCourse: Started!"

      ActiveRecord::Base.transaction do
        rows.each do |row|
          create_npq_course(row)
        end
      end

      logger.info "CreateNPQCourse: Finished!"
    end

  private

    attr_reader :path_to_csv, :logger

    def initialize(path_to_csv:, logger: Rails.logger)
      @path_to_csv = path_to_csv
      @logger = logger
    end

    def create_npq_course(row)
      NPQCourse.find_or_create_by!(
        {
          name: row["name"],
          identifier: row["identifier"],
        },
      )

      logger.info "CreateNPQCourse: Course for identifier #{row['identifier']} successfully find_or_created"
    end

    def check_headers!
      unless %w[name identifier].all? { |header| rows.headers.include?(header) }
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
