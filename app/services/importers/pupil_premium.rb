# frozen_string_literal: true

require "csv"

module Importers
  class PupilPremium < ::BaseService
    def call
      check_headers!

      rows.each do |row|
        update_school_premium(row)
      end
    end

  private

    attr_reader :start_year, :path_to_source_file

    def initialize(start_year:, path_to_source_file:)
      @start_year = start_year
      @path_to_source_file = path_to_source_file
    end

    def update_school_premium(row)
      urn = row.fetch("URN")
      school = School.find_by(urn:)
      return if school.nil?

      pupil_premium = ::PupilPremium.find_or_initialize_by(school:, start_year:)
      pupil_premium.pupil_premium_incentive = row.fetch("Pupil Premium Incentive") == "1"
      pupil_premium.sparsity_incentive = row.fetch("Sparsity Incentive") == "1"

      pupil_premium.save!
    end

    def check_headers!
      unless ["URN", "Pupil Premium Incentive", "Sparsity Incentive"].all? { |header| rows.headers.include?(header) }
        raise NameError, "Cannot find expected column headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_source_file, headers: true)
    end
  end
end
