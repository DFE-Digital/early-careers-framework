# frozen_string_literal: true

require "csv"

class PupilPremiumImporter
  attr_reader :logger
  attr_reader :start_year
  attr_reader :source_file

  def initialize(logger, start_year = Time.zone.now.year, source_file = nil)
    @logger = logger
    @start_year = start_year
    @source_file = source_file
  end

  def run
    CSV.foreach(data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      update_school_premium(row)
    end
  end

private

  def data_file
    source_file || Rails.root.join("data/pupil_premium.csv")
  end

  def update_school_premium(row)
    urn = row.fetch("URN")
    school = School.find_by(urn: urn)
    logger.info "Could not find school with URN #{urn}" and return unless school

    total_pupils = row.fetch("Number of pupils on roll (7)")
    eligible_pupils = row.fetch("Total number of pupils eligible for the Deprivation Pupil Premium")

    pupil_premium = PupilPremium.find_or_initialize_by(school: school, start_year: start_year)
    pupil_premium.total_pupils = total_pupils
    pupil_premium.eligible_pupils = eligible_pupils
    pupil_premium.save!
  end
end
