# frozen_string_literal: true

require "file_download"
require "csv"

class SchoolDataImporter
  def run
    CSV.foreach(schools_data_file.path, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
      school = row_to_school(row)
      school.save!
    end
  end

private

  def gias_schools_csv_url
    date_string = Time.zone.now.strftime("%Y%m%d")
    "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{date_string}.csv"
  end

  def schools_data_file
    FileDownload.new(gias_schools_csv_url).fetch
  end

  def row_to_school(row)
    school = School.find_or_initialize_by(urn: row.fetch("URN"))
    school.name = row.fetch("EstablishmentName")
    school.school_type = row.fetch("TypeOfEstablishment (code)").to_i
    school.capacity = row.fetch("SchoolCapacity").to_i
    school.address_line1 = row.fetch("Street")
    school.address_line2 = row.fetch("Locality")
    school.address_line3 = row.fetch("Town")
    school.address_line4 = row.fetch("County (name)")
    school.country = row.fetch("Country (name)")
    school.postcode = row.fetch("Postcode")
    dummy_domain = row.fetch("SchoolWebsite").split(/\./, 2).second
    school.domains = [dummy_domain]
    school
  end
end
