# frozen_string_literal: true

require "csv"

class PupilPremiumImporter
  def initialize(logger, start_year = Time.zone.now.year, source_file = "")
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
    @source_file || __dir__ + "/../../data/pupil_premium.csv"
  end

  def update_school_premium(row)
    urn = row.fetch("URN")
    school = School.find_by(urn: urn)
    @logger.info "Could not find school with URN #{urn}" and return unless school

    pupil_premium_eligibility = PupilPremiumEligibility.find_or_initialize_by(school: school, start_year: @start_year)
    pupil_premium_eligibility.percent_primary_pupils_eligible = row.fetch("Percentage of Primary pupils eligible for the Deprivation Pupil Premium")
    pupil_premium_eligibility.percent_secondary_pupils_eligible = row.fetch("Percentage of Secondary pupils eligible for the Deprivation Pupil Premium")
    pupil_premium_eligibility.save!
  end
end
